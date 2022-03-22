# Create.jl

Create any Julia object from a configuration file.

This package allows the creation of any Julia object from some configuration
file (such as TOML) which can be parsed into a `Dict`. For example, consider
the following TOML file which outlines a neural network using Flux.jl:

```TOML
[1]
type=":Chain"
[1.kwargs]

[1.1]
type=":Dense"
args = [10, 21, ":tanh"]
[1.1.kwargs]
":bias" = true
":init" = ":(Flux.glorot_uniform)"

[1.2]
type=":Dense"
args = [21, 3, ":tanh"]
[1.2.kwargs]
":bias" = true
":init" = ":(Flux.glorot_uniform)"

[1.3]
type="generic"
args = ["x -> Flux.softmax(x)"]
```

This configuration file, when parsed by	the `parse` function will result in a
`Flux.Chain` of `Flux.Dense(10, 21, tanh)`, followed by a `Flux.Dense(21, 3,
tanh)` and finally by a `Flux.softmax` function, outputting a softmax
distribution over 3 values.

This package was originally developed to provide configuration files for
Flux.jl neural network models, but it can be used to create **any** Julia
object from a configuration file.

## Layout of (TOML) Configuration Files

Each configuration file is treats as a *Call Tree*, which denotes function
calls with their arguments. The tree should have a single root node, which
determines which object is created. This is the first layer `[1]` in the
configuration file above, and results in the creation of a `Flux.Chain`. In
effect, the root node is a node to create a `Flux.Chain`.

Each object in the hierarchy is defined by a sequence of numbers such as
`1.2.3.4.5`. These numbers refer to arguments to function calls. For example,
above the configuration of `[1.1]` refers to the first argument to the
configuration of `[1]`. Similarly, `[1.x]` refers to the `xth` argument to the
function call defined in `[1]`. Each `.` refers to a new depth of the tree. For
example, `[1.x.y.z]` is the `zth` argument to the `yth` function call, which
itself is the `xth` argument to the final constructed object, defined in layer
`[1]`.

### `type`

Each successive layer has a `type`, which defines which function is called or
what object is created. Valid `type` values are:

Type Value   |   Interpretation
-------------|------------------
`:X`		 | Call the function `X` in the code. `X` can be any valid callable symbol which is defined in the code
`generic`    | Call any generic Julia code such as `x -> x + 1`
`function`   | Call a function with no arguments. This is syntactic sugar for `generic`, but is useful to explicitly state that we are calling a function. This was introduced to make it expicit when a function is being called in a `Flux.Chain`, e.g. a `flatten`
`constant`   | Return a constant

Custom `type`s can be registered using the `custom` function. More on that
later.

### `args`

Each configuration layer also has an associated `args` key. The value of this
must be a `Vector{Any}` and has the following interpretations:

Type Value   |   Interpretation of `args`
-------------|----------------------------
`:X`		 | Call `X(args...)`
`generic`    | The generic Julia code to call. Must be a `Vector` of length 1
`function`   | The function to call (same as `generic`)
`constant`   | The constant value to return

For example:
```TOML
type = "generic"
args = ["x -> x + 1"]
```
will return the anonymous function `x -> x + 1`. As another example, the
following will fail:
```
type = "generic"
args = ["x -> x + 1", "x -> x - 1"]
```
since the `generic` type takes only a single argument. To create an object, we
actually need to refer to it by its symbol. To create a `Flux.Dense`:
```TOML
type = ":Dense"
args = [10, 3, :relu]
```
As you can see, we also referred to the activation function by its symbol
`:relu`. In general, whenever we access symbols in the code, we must specify
them in the configuration file as a symbol. The exception to this is the
`generic` type, where we do not access symbols by their symbol representation.

### `kwargs`

# Custom `type`s
