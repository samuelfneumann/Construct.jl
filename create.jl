"""
	Create

TODO
"""
module Create
# TODO:
#	Have it so that we could call a function, which would produce some output for say e.g.
#	layers.1.1 where the last 1 refers to the first argument for layer 1. Then, in this dict
#	(i.e. layers.1.1) we could have configuration to call a function which would return
#	something, and then that returned value would be an argument to the type described in
#	layers.1. For example, layers.1 could be a Dense, and layers.1.1 could be a function
#	which gets the observation space dimensions for the environment, and returns that as the
#	input dimensions for the Dense. The output dimensions could be also done similarly

using Flux
using TOML

include("functions.jl")
include("custom.jl")

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
println(net(rand(1)))

end
