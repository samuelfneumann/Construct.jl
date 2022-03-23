include("../src/Construct.jl")

using Main.Construct
using Test
using Flux
using TOML
using Random

@testset "MersenneTwister" begin
	# twister = TOML.parsefile("./test/config/MersenneTwister.toml")
	# twister = Construct.parse(twister)

	# @test twister isa Random.MersenneTwister
end


@testset "FluxChain" begin
	net = TOML.parsefile("./test/config/FluxChain.toml")
	println(Main.Construct.parse)
	net = Construct.parse(net)
	println(net)

	@test net isa Chain
	@test net[1] isa Dense
	@test net[2] isa Dense
	@test net[4] == Flux.flatten
end
