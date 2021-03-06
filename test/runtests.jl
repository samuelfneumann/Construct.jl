include("../src/Construct.jl")

using Main.Construct
using Test
using Flux
using TOML
using Random

struct Point{T}
	x::T
	y::T
end

env_name = "MountainCar"
function state_inputs(env_name)
	if env_name == "MountainCar"
		return 2
	else
		return 3
	end
end

function outputs(env_name)
	if env_name == "MountainCar"
		return 2
	else
		return 1
	end
end

function a(n;b)
	return n + b
end

# Construct a MersenneTwister
@testset "MersenneTwister" begin
    twister = TOML.parsefile("./config/MersenneTwister.toml")
    twister = Construct.parse(twister)

    @test twister isa Random.MersenneTwister
end

# Construct a Flux Chain given constant arguments to Dense
@testset "FluxChain" begin
    net = TOML.parsefile("./config/FluxChain.toml")
    net = Construct.parse(net)

    @test net isa Chain
    @test net[1] isa Dense
    @test net[2] isa Dense
    @test net[4] == Flux.flatten
end

# Construct a Flux Chain using defined functions to generate arguments for Dense
@testset "FluxChainFromFunction" begin
    net = TOML.parsefile("./config/FluxChainFromFunction.toml")
    net = Construct.parse(net)

    @test net isa Chain
    @test net[1] isa Dense
    @test net[2] isa Dense
    @test net[4] == Flux.flatten
end

@testset "kwargs" begin
	config = TOML.parsefile("./config/kwargs.toml")
	# display(config["1"])
	# println()
	out = Construct.parse(config)

	@test out == 4
end

# Test construction of a parameterized type
@testset "ParameterizedType" begin
    config = TOML.parsefile("./config/Point.toml")
    point = Construct.parse(config)

    @test point isa Point{Int}
    @test point.x == 1
    @test point.y == 5
end

# Test construction of a parameterized type with type parameter specified
@testset "ParameterizedTypeWithTypeSpecified" begin
    config = TOML.parsefile("./config/PointSpecified.toml")
    point = Construct.parse(config)

    @test point isa Point{Int}
    @test point.x == 1
    @test point.y == 5
end

