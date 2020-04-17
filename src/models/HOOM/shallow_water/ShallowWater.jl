
include("../../../share/DisplacedPoleCoordinate.jl")

module ShallowWater

    using LinearAlgebra    
    using ..DisplacedPoleCoordinate

    include("AdvectionSpeedUpMatrix.jl")
    include("Env.jl")
    include("State.jl")
    include("TracerAdv.jl")
    include("DynamicAdv.jl")
    include("Model.jl")
    include("step_tcr_adv.jl")
    include("step_dyn_adv.jl")

    include("../rearrange.jl")
    include("var_list.jl")

    macro loop_hor(ocn, idx1, idx2, stmts)
        return :( for grid_idx in 1:size($(esc(ocn)).valid_idx)[2]

            $(esc(idx1)) = $(esc(ocn)).valid_idx[1, grid_idx]
            $(esc(idx2)) = $(esc(ocn)).valid_idx[2, grid_idx]
            $(esc(stmts))

        end )
    end


    function allocate(datakind::Symbol, dtype::DataType, dims... ; func=Main.zeros)
        if datakind == :local
            return func(dtype, dims...)
        elseif datakind == :shared
            return SharedArray{dtype}(dims...)
        else
            ErrorException("Unknown kind: " * string(datakind)) |> throw
        end
    end


    function stepModel!(
        model :: Model,
        Δt    :: Float64,
    )

        #setupFlow!(model.state)
        
        advectTracer!(model, Δt)
        advectDynamic!(model, Δt)

    end


    function advectDynamic!(model::Model, Δt::Float64)
        # 1. derive barotropic and baroclinic flow
        # 2. deri
    end

    mutable struct ABIIIObj
        gi :: DisplacedPoleCoordinate.GridInfo
        
    
        function ABIIIObj(
            ShallowWater
        )
                        
        end
    end


    function ABIII!(
        o :: ABIIIObj
    )

    end
end
