# Construct.jl Documentation

Create any Julia object from a configuration file.

This package allows the creation of any Julia object from some configuration
file (such as TOML) which can be parsed into a `Dict`. For example, consider
the following Julia code:

```julia
module Example

using Construct
using Flux
using TOML

file = ...  # Some TOML configuration file, contents of which defined below
config = TOML.parsefile(file)
net = Construct.parse(config)
end
```

with the following TOML configuration file, outlining a neural network using
Flux.jl:

```TOML
[1]
type=":(Main.Example.Chain)"
[1.kwargs]

[1.1]
type=":(Main.Example.Dense)"
args = [10, 21, ":(Main.Example.tanh)"]
[1.1.kwargs]
":bias" = true
":init" = ":(Main.Example.Flux.glorot_uniform)"

[1.2]
type=":Dense"
args = [21, 3, ":(Main.Example.tanh)"]
[1.2.kwargs]
":bias" = true
":init" = ":(Main.Example.Flux.glorot_uniform)"

[1.3]
type="generic"
args = ["x -> :(Main.Example.Flux.softmax)(x)"]
```

This configuration file, when parsed by	the `Construct.parse`
function will result in a
`Flux.Chain` of `Flux.Dense(10, 21, tanh)`, followed by a `Flux.Dense(21, 3,
tanh)` and finally by a `Flux.softmax` function, outputting a softmax
distribution over 3 values.

This package was originally developed to provide configuration files for
Flux.jl neural network models, but it can be used to create **any** Julia
object from a configuration file.

## Contents

```@contents
```

## Functions

Construct.jl exports two functions. `parse` is the workhorse of object
construction. `custom` allows you to add custom functionality to your
configuration files as outlined in [Custom Types](@ref).
Configuration file structure is described in [General Structure](@ref).

```@docs
Construct.parse(config::Dict{String, Any})
Construct.custom(type::String, op::Function)

```

## Index

```@index
```
