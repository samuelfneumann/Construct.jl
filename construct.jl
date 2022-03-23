module Construct

using Flux
using TOML
using Test

include("functions.jl")
include("custom.jl")

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

net = TOML.parsefile("net.toml")

net = parse(net)

println(net)
println(typeof(net))
println(net(rand(state_inputs(env_name))))

end
