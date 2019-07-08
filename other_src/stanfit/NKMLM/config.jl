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
        "sub-output-size" => 1,
        "output-root-dir" => data_dir,
        "SST-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.SST.100001-109912.nc"),
        "SHF-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.SHF.100001-109912.nc") ,
        "MLD-file"        => joinpath(data_dir, "transformed_b.e11.B1850C5CN.f45_g37.005.pop.h.HMXL.100001-109912.nc") ,
        "stan-chains"     => 1,
        "stan-samples"    => 100,
        "stan-warmup"     => 10,
        "sub-output-size" => 1,
        "T-sigma"         => 1.0,
        "output-root-dir" => data_dir,
        "exp-name"        => "LENS.g37",
    )

    config["exp-name"] = format("{:s}_c{:d}_s{:d}_w{:d}", config["exp-name"], config["stan-chains"], config["stan-samples"], config["stan-warmup"])
    config["main-dir"] = joinpath(config["output-root-dir"], config["exp-name"])

end


