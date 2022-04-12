# Custom Types

Custom types can be implemented in two way. First, you can just make a custom
struct and then use a configuration file to create it. Second, you can register
a function to be called on a specific type using the `custom` method. For
example, calling `Construct.custom(type, f)` will cause `f` to be called with
`args` and `kwargs` whenever `type` is encountered in a configuration file. For
example if `custom("agent", start_agent)` is called in your code then whenever
a configuration file has something like:

```TOML
[1.x]
type = "agent"
args = [...]
[1.x.kwargs]
...
```

then `start_agent(args...; kwargs...)` will be called when parsing the
configuration file.

