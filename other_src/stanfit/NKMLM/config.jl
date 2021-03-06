using Formatting

# Check:
#
# model_name
# nchains, num_samples, num_warmup
# exp_name [contains initial condition status]
# 
# sbatch --job-name, --output, --cpus-per-task, --time, --array

let
    data_dir = normpath(joinpath(dirname(@__FILE__)), "..", "..", "..", "data")

    global config = Dict(
        "output-root-dir" => data_dir,
        "SST-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.SST.100001-109912.nc"),
        "SHF-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.SHF.100001-109912.nc") ,
        "MLD-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.HMXL.100001-109912.nc") ,
        "stan-chains"     => 2,
        "stan-samples"    => 500,
        "stan-warmup"     => 100,
        "sub-output-size" => 10,
        "T-sigma"         =>  0.1,
        "h_mean-sigma"    => 10.0,
        "output-root-dir" => data_dir,
        "exp-name"        => "LENS.g37",
        "steps"           => [2 for _ in 1:12],
    )

    config["exp-name"] = format("NKMLM_{:s}_c{:d}_s{:d}_w{:d}", config["exp-name"], config["stan-chains"], config["stan-samples"], config["stan-warmup"])
    config["main-dir"] = joinpath(config["output-root-dir"], config["exp-name"])

end



