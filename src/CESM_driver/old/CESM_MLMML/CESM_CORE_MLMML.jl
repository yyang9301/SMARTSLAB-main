include("../../MLMML/MLMML.jl")
module CESM_CORE_MLMML

    using Formatting
    using ..NetCDFIO
    using ..MLMML
    using NCDatasets

    zs = collect(Float64, range(0, -500, step=-5))
    name = "MLMML"

    include("Workspace_MLMML.jl")
    include("../../share/StatObj.jl")

    days_of_mon = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    mutable struct MLMML_DATA
        map         :: NetCDFIO.MapInfo
        occ         :: MLMML.OceanColumnCollection

        x2o         :: Dict
        o2x         :: Dict

        output_vars :: Dict
        wksp        :: Workspace

        sobj        :: StatObj
        sobj_dict   :: Dict
    end


    function init(;
        map       :: NetCDFIO.MapInfo,
        init_file :: Union{Nothing, AbstractString},
        t         :: AbstractArray{Integer},
    )

        if init_file == nothing
            println("No initial ocean profile. Using the naive one.")
            occ = let

                zs = collect(Float64, range(0, -500, step=-5))
                K_T = 1e-5
                K_S = 1e-5

                init_h_ML     = MLMML.h_ML_min
                
                init_T_ML     = 288.0
                init_T_slope  = 2.0 / 4000.0
                init_ΔT       = 5.0

                init_S_ML     = MLMML.S_ref 
                init_S_slope  = 0.0
                init_ΔS       = 0.0

                MLMML.makeBasicOceanColumnCollection(
                    map.nx, map.ny, zs;
                    T_ML     = init_T_ML,
                    ΔT       = init_ΔT,
                    T_slope  = init_T_slope,
                    S_ML     = init_S_ML,
                    ΔS       = init_ΔS,
                    S_slope  = init_S_slope,
                    h_ML     = MLMML.h_ML_min,
                    K_T      = K_T,
                    K_S      = K_S,
                    mask     = map.mask,
                )
            end

            snapshot_file = format("Snapshot_{:04d}0101_00000.nc", t[1])
            println("Output snapshot: ", snapshot_file)
            MLMML.takeSnapshot(occ, snapshot_file)

        else
            println("Initial ocean with profile: ", init_file)
            occ = MLMML.loadSnapshot(init_file)
        end

        wksp = Workspace(occ.Nx, occ.Ny, occ.Nz)

        x2o = Dict(
            "SWFLX"  => wksp.swflx,
            "NSWFLX" => wksp.nswflx,
            "TAUX"  => wksp.taux,
            "TAUY"  => wksp.tauy,
            "IFRAC" => wksp.ifrac,
            "FRWFLX" => wksp.frwflx,
        )

        o2x = Dict(
            "SST"      => occ.T_ML,
            "QFLX2ATM" => occ.qflx2atm,
        )

        output_vars = Dict(
      #      "rain"       => wksp.frwflx,
#=
            "mld"       => occ.h_ML,
            "sst"       => occ.sst,
            "qflx2atm"  => occ.qflx2atm,
            "sumflx"    => wksp.sumflx,
            "fric_u"    => wksp.fric_u,
            "ifrac"     => wksp.ifrac,
        =#)
        
        sobj_dict = Dict(
            "mld"    => occ.h_ML,
            "T"      => occ.Ts,
            "S"      => occ.Ss,
            "sumflx" => wksp.sumflx,
            "fric_u" => wksp.fric_u,
            "frwflx" => wksp.frwflx,
        )

        return MLMML_DATA(
            map,
            occ,
            x2o,
            o2x,
            output_vars,
            wksp,
            StatObj(sobj_dict),
            sobj_dict,
        )

    end

    function run(
        MD    :: MLMML_DATA;
        t     :: AbstractArray{Integer},
        t_cnt :: Integer,
        Δt    :: Float64,
    )

        #=
        # ===== monthly statistics begin =====
        if t_cnt == 1 
            zeroStatObj!(MD.sobj)
        end

        addStatObj!(MD.sobj, MD.sobj_dict)
        
        # Do monthly average and output it by the end of month
        if days_of_mon[t[2]] == t[3] && t[4] == 0
            avg_file = format("avg_{:04d}{:02d}.nc", t[1], t[2])
            
            normStatObj!(MD.sobj)

            MLMML._createNCFile(MD.occ, avg_file, MD.map.missing_value)

            Dataset(avg_file, "a") do ds

                for v in ["mld", "sumflx", "fric_u", "frwflx"]
                    MLMML._write2NCFile(ds, v, ("Nx", "Ny",), MD.sobj.vars[v], MD.map.missing_value)
                end

                for v in ["T", "S"]
                    MLMML._write2NCFile(ds, v, ("Nx", "Ny", "Nz"), MD.sobj.vars[v], MD.map.missing_value)
                end

            end
            println("Output monthly average: ", avg_file)
            
           zeroStatObj!(MD.sobj)
        end
        # ===== monthly statistics end =====
        =#

        # Take snapshot every first day of the year.
        if t[2] == 1 && t[3] == 1 && t[4] == 0
            snapshot_file = format("Snapshot_{:04d}{:02d}{:02d}_{:05d}.nc", t[1], t[2], t[3], t[4])
            MLMML.takeSnapshot(MD.occ, snapshot_file)
            println("Output snapshot: ", snapshot_file)
        end
        
        wksp = MD.wksp

        wksp.nswflx .*= -1.0
        wksp.swflx  .*= -1.0

        #wksp.sumflx[:, :]  = wksp.nswflx
        #wksp.sumflx      .+= wksp.swflx
        
        wksp.fric_u .= sqrt.(sqrt.((wksp.taux).^2.0 .+ (wksp.tauy).^2.0) / MLMML.ρ)
        wksp.weighted_fric_u .*= (1.0 .- wksp.ifrac)

        MLMML.stepOceanColumnCollection!(
            MD.occ;
            fric_u = wksp.weighted_fric_u,
            swflx  = wksp.swflx,
            nswflx = wksp.nswflx,
            frwflx = wksp.frwflx,
            Δt     = Δt,
        )



    end

    function final(MD::MLMML_DATA)
        
    end

end
