"""
	Construct

A module
"""
module Construct
export parse

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

function f(n; m, a)
	return n + m + a
end

config = TOML.parsefile("f.toml")
println(config)

println(Construct.parse(config))

config = TOML.parsefile("rng.toml")
println(config)
println(Construct.parse(config) isa MersenneTwister)

config = TOML.parsefile("net.toml")
println(config)
net = Construct.parse(config)
println(net isa Flux.Chain)
println(net[1] isa Flux.Dense)
println(net[4] == Flux.flatten)
println()
end

