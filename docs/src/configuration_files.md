# General Structure

Configuration files are parsed as *Call Trees*, which denote function calls
with their arguments.
The tree should have a single root node, which determines which
object is created. The root node should have the key `1` in the top-level
configuration of the dictionary.
Each node in the tree is composed of a `type` with arguments
`args` and keyword arguments `kwargs`. The general structure of a node is:

```
type = ...
args = [...]
kwargs = {...}
```

where `args` is a sequence of values outlining the arguments to `type`
and `kwargs` is a map outlining the keyword arguments to `type`, both of which
may be optional.
`args` and `kwargs` can also be defined in sub-configuration dictionaries.
`type` itself is described in [Types](@ref).

What ends up happening is that when this configuration file is parsed, the
above configuration will be replaced with `type(args...; kwargs...)` in Julia.

One caveat to this package is that symbols must be **fully qualified** unless the
name is accessible from the Julia REPL **without** importing any other modules.
That is, any Julia symbol in `Base` can be used without being fully qualified.
Other than that, any symbol must be fully qualified, where the
qualification refers to the symbol as imported in the current module. For
example, if Flux.jl is imported, then we refer to the `Flux.Dense` as
`Main.Example.Dense` or `Main.Example.Flux.Dense`, not `Flux.Dense`.

For the rest of this tutorial, we will assume that we are working in a module
called `Main.Example`.

## Types

A `type` describes a struct to construct or a function to call. For example,
the `generic` type will call any generic Julia code and replace its return
value at the position in the configuration file. A `constant` type will
return a constant value, and a `:(Main.Example.C)` type will construct the
struct `C`.  A description of a `type` is always a `String`.

### :X

The syntax `:X` allows us to create a struct or run a function with the symbol
`X`. To this function, we can pass in any arguments using the `args` key, or we
can create a subtree below this node, where each path in the subtree will
denote a sequential argument. If the `:X` node is at position `1.x` in the
tree, then the `yth` argument to `:X` will be at position `1.x.y`. Hence, we
have an ordering of arguments. The benefit to this approach is that any
argument to the function can be a subtree of many, many elements, and so it's
easy to construct complex objects or call functions on complex objects.

For example, if we want to create struct `A`, but struct `A` takes in struct
`B`, which takes in struct `C` to their respective constructor
arguments, we can easily do the following:
```TOML
[1]
type = ":(Main.Example.A)"

[1.1]
type = ":(Main.Example.B)"

[1.1.1]
type = ":(Main.Example.C)"

[1.1.1.y]
# Arguments to create C, where y = 1, 2, 3, ...

[1.1.x]
# Other arguments to create B, where x = 2, 3, 4, ...

[1.z]
# Other arguments to create A, where z = 2, 3, 4, ...
```
This effectively creates an object similarly to calling
`A(B(C(...), ...), ...)` in the `Example` module.

One caveat to using `:X` is that names must be **fully qualified** unless the
name is accessible from the Julia REPL **without** importing any other modules.
That is, any Julia symbol in `Base` can be used without being fully qualified.
Other than that, you any symbol must be fully qualified, where the
qualification refers to the symbol as imported in the current module. For
example, if Flux.jl is imported, then we refer to the `Flux.Dense` as
`Main.Example.Dense` or `Main.Example.Flux.Dense`, not `Flux.Dense`.

The drawback of using `:X` is that all symbols in the code
**must** be referred to as symbols, otherwise it's impossible to tell when the
configuration is specifying a `String` or some object referred to by a
`Symbol`. The benefit of `:X` is that it's
powerful and can create complex hierarchies of objects.

### generic

With the `generic` type, we can call any arbitrary Julia code by passing the
code as a single argument in `args`, and `args` must be of length 1. For
example, to return a function we could do:

```TOML
[1]
type = "generic"
args = ["x -> x + 1"]
```

parsing this configuration file would then result in an anonymous function
which adds 1 to its argument.

The benefit of using `generic` is that we don't have to refer to
anything by symbols.

### constant

With the `constant` type, we can return any constant value, defined by the
single value in the `args` array. If `length(args) != 1`, we'll get an error.
For example, to return a `1` at the current configuration layer:

```TOML
[1]
type = "constant"
args = [1]
```

## Arguments

The positional arguments to a `type` are `args`. These can have two separate
forms, but **the two forms cannot be mixed**.

In the first form, we can simply list the arguments as a sequence of values,
for example:

```TOML
type = "type1"
args = [1, "hello", 2, "world", 0.1f0]
```

where `args[i]` is the `ith` positional argument to `type`.

In the second form, we can list the arguments in a dictionary. In such a case,
each key should correspond to the argument's position in the call to `type`.
For example, if we have a `type` called `"RNG"` that has a constructor
`RNG(n::Int, s::String)`, then the `args` dictionary should map the key `1` to
an `Int` and the key `2` to a `String`. For example:

```TOML
[1]
type = "Main.Example.RNG"

[1.1]
type = "constant"
args = [1]

[1.2]
type = "constant"
args = ["hello world"]
```

The result of the above example configuration file would be to call `RNG(1,
"hello world")` in the Julia code. This dictionary form of `args` allows us to
construct complex arguments with relatively straightforward, easy-to-read code
by making the value of one of these positional arguments a configuration for
another `type`. For example, to construct a Flux.jl
`Chain(Dense(10, 10, relu))`:

```TOML
[1]
type = ":(Main.Example.Chain)"

[1.1]
type = ":(Main.Example.Dense)"
args = [10, 10, ":(Main.Example.relu)"]
```

## Keyword Arguments

Keyword arguments for a layer are placed in a sub-dictionary for the layer
For example, the keyword arguments for layer `[1.x.y]` are
placed at `[1.x.y.kwargs]` in a TOML file.
Each keyword argument is simply listed as a key-value pair:

```TOML
[1.x.y]
type = t # Some type
args = s # Sequence of arguments
[1.x.y.kwargs]
":key1" = value1
":key2" = value2
...
```

Alternatively, you can specify a keyword arguments as another key in the
configuration, similarly to a positional argument:

```TOML
[1.x.y]
type = t # Some type
args = s # Sequence of arguments
[1.x.y.kwarg1]
type = t1 # Some type
args = s1 # Sequence of arguments
...
```

Or even a mixture of the two types

```TOML
[1.x.y]
type = t # Some type
args = s # Sequence of arguments
[1.x.y.kwargs]
":key1" = value1
[1.x.y.kwarg2]
type = t1 # Some type
args = s1 # Sequence of arguments
...
```

Note that the keys are represented as Julia symbols (start with a `:`) and must
be wrapped in `"`.

Only the `:X` builtin `type` takes keyword arguments. If keyword arguments
are specified for any other builtin `type`, then an error will be
raised. Custom `type`s can be implemented to take keyword arguments.

