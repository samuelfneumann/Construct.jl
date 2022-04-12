"""
	_Custom

Singleton class which manages custom configuration functionality.

This class manages custom functionality which can be dynamically added to the creation
mechanism. For example, the user can, at runtime, register a new function to be called.
Then, when a configuration file is processed, it can then contain this new function and this
function can be called during the configuration process.
"""
struct _Custom
	_op::Dict{Any, Function}

	function _Custom()
		return new(Dict{Any, Function}())
	end
end

"""
	custom(type::String, op::Function)

Register a custom function to be called for `type`.

Whenever a type of `type` is encountered in a configuration dictionary `dict`,
call `op(dict["args"]...; dict["kwargs"]...)`.

# Example
```juliaREPL
julia> custom("generic", x -> eval(Meta.parse(x)))
julia> custom("constant", x -> x)
```
"""
custom(type::String, op::Function) = _custom._op[type] = op

"""
	constant(x)

Return x
"""
constant(x) = return x

"""
	generic(x::String)

Parse and evaluate generic Julia code
"""
generic(x::String) = return eval(Meta.parse(x))

"""
Singleton instance of _Custom
"""
const _custom = _Custom()



"""
	_op

Run the operation associated with the configuration dictionary's `type`
"""
function _op(dict)
	if !("type" in keys(dict))
		error("no key 'type' in input dictionary")
	end
	type = dict["type"]

	if "kwargs" in keys(dict)
		kwargs = dict["kwargs"]
	else
		kwargs = Dict()
	end

	return _custom._op[type](dict["args"]...; kwargs...)
end

"""
	_is_custom

Return whether `dict` is describing a custom type, i.e. one registered with `_Custom`
"""
function _is_custom(dict)::Bool
	if !("type" in keys(dict))
		return false
	end
	type = dict["type"]

	return type in keys(_custom._op)
end
