# TOML Configuration Files

Each object in the configuration
hierarchy is defined by a sequence of numbers such as
`1.2.3.4.5`. These numbers refer to arguments to function calls. For example,
above the configuration of `[1.1]` refers to the first argument to the
configuration of `[1]`. Similarly, `[1.x]` refers to the `xth` argument to the
function call defined in `[1]`. Each `.` refers to a new depth of the tree. For
example, `[1.x.y.z]` is the `zth` argument to the `yth` function call, which
itself is the `xth` argument to the final constructed object, defined in layer
`[1]`.

Each successive configuration layer has the following form:

```TOML
[x]
type = t # some type description
args = s # a sequence of values
[x.kwargs]
# key = value pairs
```

where `x` can be any sequence of numbers separated by a `.`, `t` is some type
description, and `s` is a sequence of values. Alternatively the `args` can be
specified in a nested dictionary, as described in [General Structure](@ref).
For example:

```TOML
[x]
type = t # some type description
[x.1]
type = t1 # some type description
args = s1 # a sequence of values
# More arguments of the form [x.y]
[x.kwargs]
# key = value pairs
```

In this form, we could actually have the `args` of `[x.1]` be similarly a
nested dictionary as well. We can have any number of nested dictionaries
describing consecutive objects to construct.
