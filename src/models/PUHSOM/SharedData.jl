
mutable struct DataMapping
    # shape can be either :xyz or :zxy
    fr_shape  :: Symbol
    to_shape  :: Symbol
    fr      :: Symbol
    to      :: Symbol
end

mutable struct DataUnit
    id          :: Symbol
    grid        :: Symbol      # could be (f, c, s) x (T, U, V, W)
    shape       :: Symbol    # could be :xy, :xyz, :zxy
    data        :: AbstractArray
end


mutable struct SharedData

    env        :: OcnEnv
    data_units :: Dict{ Symbol, DataUnit }

    function SharedData(
        env::OcnEnv
    )


        data_units = Dict{Symbol, DataUnit}()

        return new(
            env,
            data_units,
        )

    end

end

function regVariable!(
    sd       :: SharedData,
    env      :: OcnEnv,
    id       :: Symbol,
    grid     :: Symbol,
    shape    :: Symbol,
    dtype    :: DataType;
    data     :: Union{Nothing, SharedArray{T}} = nothing,
) where T


    env = sd.env
    Nx, Ny, Nz_f, Nz_c = env.Nx, env.Ny, env.Nz_f, env.Nz_c

    if haskey(sd.data_units, id)
        throw(ErrorException("Error: variable id " * String(id) *  " already exists."))
    end

    dim = Dict(
        :fT => [Nx  , Ny  , Nz_f],
        :fU => [Nx  , Ny  , Nz_f],
        :fV => [Nx  , Ny+1, Nz_f],
        :fW => [Nx  , Ny  , Nz_f+1],
        :cT => [Nx  , Ny  , Nz_c],
        :cU => [Nx  , Ny  , Nz_c],
        :cV => [Nx  , Ny+1, Nz_c],
        :cW => [Nx  , Ny  , Nz_c+1],
        :sT => [Nx  , Ny],
        :sU => [Nx  , Ny],
        :sV => [Nx  , Ny],
    )[grid]

    if ! (shape in (:xy, :xyz, :zxy))
        throw(ErrorException("Error: only :xy, :xyz, :zxy are accepted in shape"))
    end

    if grid in (:sT, :sU, :sV)
        if shape in (:xyz, :zxy)
            throw(ErrorException("Error: grid and shape mismatch. Slab grid should only be with :xy shape."))
        end
    else
        if shape == :zxy
            dim = circshift(dim, 1)
        end
    end

    if ! (dtype in (Float64, Int64))
        throw(ErrorException("Invalid data type. Only Float64 and Int64 are accepted"))
    end

    if data == nothing
        data = SharedArray{dtype}(dim...)
    else

        if Tuple(dim) != size(data)
            println("Expect ", dim)
            println("Get ", size(data))
            throw(ErrorException("Provided data does not have correct dimension."))
        end

        if dtype != T
            throw(ErrorException("dtype and provided data does not match."))
        end
    end

    sd.data_units[id] = DataUnit(
        id,
        grid,
        shape,
        data,
    )
end
