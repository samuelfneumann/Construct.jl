using Create
using Base.Test
using Flux

@testset "Flux Chain" begin
	net = TOML.parsefile("net.toml")

	@test net isa Chain
	@test net[1] isa Dense
end
