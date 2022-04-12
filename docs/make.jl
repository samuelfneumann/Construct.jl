push!(LOAD_PATH, "../src")
using Documenter, Construct

makedocs(
	sitename="Construct.jl",
	pages = [
		"index.md",
		"Configuration Files" => [
			"configuration_files.md",
			"toml.md",
			"json.md",
		],
		"custom_types.md",
	],
	)
