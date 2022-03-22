"""
	Create

TODO
"""
module Create

using Flux
using TOML

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

net = TOML.parsefile("net.toml")

# display(net)
# println()
# out = Dict()
# _parse_symbol(net, out)
# println()
# println("OUT =========")
# display(out["layers"][1])
# println()
# display(out["layers"][1][1])
# println()
# display(out["layers"][1][2])
# println("OUT =========")
# println()

# d = out["layers"][1][1]
# constructor = d["type"]
# args = values(d["args"])
# println("ARGS: ", args[end] isa Symbol)
# kwargs = d["kwargs"]

# println(constructor(args...; kwargs...))

# net = make(out)
net = parse(net)
println(net)
println(typeof(net))
println(net(rand(state_inputs(env_name))))

end
