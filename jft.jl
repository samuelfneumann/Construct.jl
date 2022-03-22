# TODO:
#	Allow mixture of args = [...] and args from construction. This will basically just be
#	more leaves, each with their position N and then a single key-value pair. For example
#	arg = ...

using Flux
using TOML

function _to_int(elem)
	if elem isa String
		elem = lowercase(elem)
		if elem == "args" || elem == "kwargs" || elem == "type"
			return elem
		end

		return tryparse(Int, elem)

	elseif elem isa Integer
		return Int(elem)

	end

	return nothing
end

# Recursively traverse the dict, creating all objects
function make(net::Dict{Any, Any})
	# Parse a generic expression if given
	dict_keys = collect(keys(net))
	if "type" in dict_keys && net["type"] == "generic"
		return eval(Meta.parse(net["expr"]))
	end

	# Remove the args, kwargs, and type keys
	if "type" in dict_keys
		deleteat!(dict_keys, findall(x -> x == "type", dict_keys))
	end
	if "args" in dict_keys
		deleteat!(dict_keys, findall(x -> x == "args", dict_keys))
	end
	if "kwargs" in dict_keys
		deleteat!(dict_keys, findall(x -> x == "kwargs", dict_keys))
	end

	if length(dict_keys) == 1
		key = collect(keys(net))[1]
		if key == "arg"
			return net["arg"]
		elseif !(net[key] isa Dict)
			return error("expected a Dict but got $(typeof(net[key]))")
		end
		return make(net[key])
	end

	args = []

	# Ensure all keys are numeric
	int_dict_keys = _to_int.(dict_keys)
	if nothing in int_dict_keys
		i = findall(x -> x === nothing, int_dict_keys)[1]
		arg = dict_keys[i]
		error("config keys should be all numeric but got $arg")
	end
	dict_keys = int_dict_keys

	dict_keys = sort(dict_keys)
	for k in dict_keys
		push!(args, make(net[k]))
	end

	# Construct the object
	constructor = net["type"]
	if "kwargs" in keys(net)
		kwargs = net["kwargs"]
	else
		kwargs = Dict()
	end
	if "args" in  keys(net) && length(args) != 0
		error("args specified twice")
	elseif length(args) == 0 && "args" in keys(net)
		args = net["args"]
	end

	return constructor(args...; kwargs...)
end

function _parse_key(key)
	# Check if the key is a symbol
	new_key = _parse_symbol(key; value=false)

	# If the key is not a symbol, check if it is a number and cast to an Int
	if !(new_key isa Symbol)
		digit_key = tryparse(Int, new_key)
		if !(digit_key === nothing)
			new_key = digit_key
		end
	end

	return new_key
end

function _parse_symbol(net::Dict{String, Any}, out::Dict{Any, Any})::Dict{Any, Any}
	for key in keys(net)

		new_key = _parse_key(key)

		if net[key] isa Dict
			out[new_key] = _parse_symbol(net[key], Dict())
		elseif net[key] isa String && net[key][1] == ':'
			out[new_key] = eval(Meta.parse(net[key][2:end]))
		elseif lowercase(key) == "args"
			out[new_key] = _parse_symbol.(net[key]; value=true)
		else
			out[new_key] = eval(_parse_symbol(net[key]))
		end
	end

	return out
end

function _parse_symbol(elem; value=false)
	if elem isa String && elem[1] == ':'
		if value
			return eval(Meta.parse(elem[2:end]))
		end
		return Meta.parse(elem[2:end])
	end

	return elem
end


net = TOML.parsefile("net.toml")

display(net)
println()
out = Dict()
_parse_symbol(net, out)
println()
println("OUT =========")
display(out["layers"][1])
println()
display(out["layers"][1][1])
println()
display(out["layers"][1][2])
println("OUT =========")
println()

d = out["layers"][1][1]
constructor = d["type"]
args = values(d["args"])
println("ARGS: ", args[end] isa Symbol)
kwargs = d["kwargs"]

println(constructor(args...; kwargs...))

net = make(out)
println(net)
println(typeof(net))
println(net(rand(1)))


