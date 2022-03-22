"""
	parse(config::Dict{String, Any}

Parse and return the object defined by `config`
"""
function parse(config::Dict{String, Any})
	num = length(config)
	if num != 1
		error("can only create a single object, but root of tree has $num objects")

		return nothing
	end
	out = _parse_symbol(net, Dict())

	return _parse(out)
end

"""
	_parse(config::Dict{Any, Any})

Traverse the configuration dictionary `config` and create the described object. The
configuration dictionary should be such that all symbols are defined, that is, any symbol
referring to a function call or constructor call should not be a string representation, but
rather should be a reference to the function.
"""
function _parse(config::Dict{Any, Any})
	# If the type is a custom type, perform the custom type functionality and return
	if _is_custom(config)
		return _op(config)
	end

	# Remove the args, kwargs, and type keys
	dict_keys = collect(keys(config))
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
		key = collect(keys(config))[1]
		if !(config[key] isa Dict)
			return error("expected a Dict but got $(typeof(config[key]))")
		end
		return _parse(config[key])
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
		push!(args, _parse(config[k]))
	end

	# Construct the object
	constructor = config["type"]
	if "kwargs" in keys(config)
		kwargs = config["kwargs"]
	else
		kwargs = Dict()
	end
	if "args" in  keys(config) && length(args) != 0
		error("args specified twice")
	elseif length(args) == 0 && "args" in keys(config)
		args = config["args"]
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

function _parse_symbol(config::Dict{String, Any}, out::Dict{Any, Any})::Dict{Any, Any}
	for key in keys(config)

		new_key = _parse_key(key)

		if config[key] isa Dict
			out[new_key] = _parse_symbol(config[key], Dict())
		elseif config[key] isa String && config[key][1] == ':'
			out[new_key] = eval(Meta.parse(config[key][2:end]))
		elseif lowercase(key) == "args"
			out[new_key] = _parse_symbol.(config[key]; value=true)
		else
			out[new_key] = eval(_parse_symbol(config[key]))
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


