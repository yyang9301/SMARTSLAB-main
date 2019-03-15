
include("MLMML.jl")


module SSM

using Printf
using Formatting
using ..MLMML

missing_value = 1e20

include("takeSnapshot.jl")

function stepOceanColumnCollection!(;
    occ   :: MLMML.OceanColumnCollection,
    Δt    :: Float64,
)

    wksp = occ.wksp
    
    wksp.fric_u .= sqrt.(sqrt.((wksp.taux).^2.0 .+ (wksp.tauy).^2.0) / MLMML.ρ)
    wksp.weighted_fric_u .*= (1.0 .- wksp.ifrac)

    wksp.hflx   .*= (MLMML.α * MLMML.g / MLMML.ρ / MLMML.c_p)
    wksp.swflx  .*= (MLMML.α * MLMML.g / MLMML.ρ / MLMML.c_p)
    
    MLMML.stepOceanColumnCollection!(
        occ;
        fric_u = wksp.weighted_fric_u,
        B0     = wksp.hflx,
        J0     = wksp.swflx,
        Δt     = Δt,
    )
end

function maskData!(occ::MLMML.OceanColumnCollection, arr::AbstractArray{Float64})
    for i = 1:occ.N_ocs
        if occ.mask[i] == 0.0
            arr[i] = missing_value
        end
    end
end


#=
function getInfo!(;
    occ      :: MLMML.OceanColumnCollection,
    sst      :: Union{AbstractArray{Float64}, Nothing} = nothing,
    mld      :: Union{AbstractArray{Float64}, Nothing} = nothing,
    qflx2atm :: Union{AbstractArray{Float64}, Nothing} = nothing,
)
    if mld != nothing
        for l = 1:occ.N_ocs
            if occ.mask[l] == 0.0
                continue
            end
            mld[l] = occ.ocs[l].h_ML
        end
    end

    if sst != nothing

        for l = 1:occ.N_ocs

          if occ.mask[l] == 0.0
              continue
          end
          sst[l] = occ.ocs[l].b_ML / (MLMML.α * MLMML.g) + MLMML.T_ref
        end

    end

    if qflx2atm != nothing
        for l = 1:occ.N_ocs
            if occ.mask[l] == 0.0
                continue
            end
            qflx2atm[l] = occ.ocs[l].qflx2atm
        end
    end

end
=#


end
