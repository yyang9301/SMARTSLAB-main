using Distributed

@everywhere module NKOM

    using Printf
    using Formatting
    using SharedArrays
    using Distributed
    using SparseArrays
    using NCDatasets

    macro hinclude(path)
        return :(include(normpath(joinpath(@__DIR__, $path))))
    end
 
    @hinclude("../share/DisplacedPoleCoordinate.jl")
    @hinclude("../share/MapInfo.jl")
       
    @hinclude("../share/constants.jl")
    @hinclude("OceanColumnCollection.jl")
    @hinclude("trivial_functions.jl")

    @hinclude("calWeOrMLD.jl")
    @hinclude("doConvectiveAdjustment.jl")
    @hinclude("doDiffusion.jl")
    @hinclude("getIntegratedBuoyancy.jl")
    @hinclude("doNewtonianRelaxation.jl")
    @hinclude("stepOceanColumnCollection.jl")


    @hinclude("setOceanColumn.jl")
    @hinclude("takeSnapshot.jl")

end

