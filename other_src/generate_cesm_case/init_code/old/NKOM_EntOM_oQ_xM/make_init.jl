include(joinpath("..", "load_files.jl"))
include(joinpath(src, "NKOM", "NKOM.jl"))
using .NKOM

ocn = NKOM.Ocean(
    gridinfo_file = parsed["domain-file"],
    Nx       = Nx,
    Ny       = Ny,
    zs_bone  = zs,
    Ts       = copy(Ts_clim),
    Ss       = copy(Ss_clim),
    T_ML     = Ts_clim[:, :, 1],
    S_ML     = Ss_clim[:, :, 1],
    h_ML     = 10.0, 
    h_ML_min = 10.0,
    h_ML_max = 1e5,             # make it unrestricted
    mask     = mask,
    topo     = topo,
    Ts_clim_relax_time = 0.0, # Fixed
    Ts_clim            = copy(Ts_clim),
    Ss_clim_relax_time = 0.0, # Fixed
    Ss_clim            = copy(Ss_clim),
    arrange  = :xyz,
)

NKOM.takeSnapshot(ocn, parsed["output-file"])

