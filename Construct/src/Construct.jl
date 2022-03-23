module Construct
export set, parse

include("Functions.jl")
include("Custom.jl")

# Register some extra functionality
custom("generic", generic)
custom("constant", constant)
custom("function", generic)
end

module Run
using Main.Construct
using TOML
using Random
using Flux

env_name = "MountainCar"
function state_inputs(x)
	if env_name == "MountainCar"
		return 2
	else
		return 3
	end
end

function outputs(x)
	if env_name == "MountainCar"
		return 2
	else
		return 1
	end
end

config = TOML.parsefile("rng.toml")
println(config)
println(Construct.parse(config) isa MersenneTwister)

config = TOML.parsefile("net.toml")
println(config)
println(Construct.parse(config))
end

