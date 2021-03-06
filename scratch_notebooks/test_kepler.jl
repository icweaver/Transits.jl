### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 12d523ae-7b24-11eb-3e11-5581a47e1b90
begin
	using Revise
	using AstroLib: trueanom, kepler_solver
	using PhysicalConstants
	using PlutoUI
	using PyCall
	using Transits.Orbits: KeplerianOrbit, relative_position
	using Unitful, UnitfulAstro
	using StatsPlots
end

# ╔═╡ 132e3b14-7d78-11eb-3591-bb0f1288b88e
using Test

# ╔═╡ 3893efb6-7d6e-11eb-32bb-1bfcc375b17d
# Compute sin_ν, cos_ν without using arctan function directly
function compute_sincos_ν_no_atan(E, ecc)
	sin_E, cos_E = sincos(E)
	denom = 1.0 + cos_E
	x = √((1 + ecc) / (1 - ecc)) * sin_E / denom # where ν = 2 arctan(x)
	x² = x * x
	# Apply trig identites:
	#     sincos(arctan x) = (x, 1) ./ √(1 + x²)
	#     sincos(ν) = 2 sin(arctan x)cos(arctan x), 1 - 2 sin²(arctan x)
	denom = 1.0 / (1.0 + x²)
	sin_ν = 2.0 * x * denom
	cos_ν = (1.0 - x²) * denom
	return sin_ν , cos_ν
end

# ╔═╡ f6705594-7d6c-11eb-3624-53324bb04681
function compute_E_solver(E, ecc)
	M =  E - ecc * sin(E)
	return kepler_solver(M, ecc) # <- E
end

# ╔═╡ 75d06d62-7d73-11eb-3db7-97c3cbaebdb9
function edge(E, ecc)
	E = rem2pi(E, RoundNearest)
	# Computed from solver
	E_solver = compute_E_solver(E, ecc)
	println(E_solver)
	sin_ν_solver, cos_ν_solver = compute_sincos_ν_no_atan(E_solver, ecc)
	# Computed directly
	sin_ν, cos_ν = sincos(trueanom(E, ecc))
	return [E_solver, E, sin_ν_solver, sin_ν, cos_ν_solver, cos_ν]
end

# ╔═╡ e396ab44-7d2b-11eb-2f91-7573ef462559
md"""
#### Test
"""

# ╔═╡ 44c8b5ac-7d6c-11eb-17c5-5f22ffe3e385
Es = [0.0, 2 * π, -226.2, -170.4]

# ╔═╡ 318c1376-7e0c-11eb-23ed-d14627a8c653
eccs = fill(1.0 - 1e-6, length(Es))

# ╔═╡ 318c7c6c-7e0c-11eb-16e9-9b70f4571225
eccs[end] = 0.9939879759519037

# ╔═╡ 31077a28-7d7e-11eb-340c-77db01116fc1
(
	E_solver,     E_user,
	sin_ν_solver, sin_ν_user,
	cos_ν_solver, cos_ν_user,
) = eachrow(hcat(edge.(Es, eccs)...));

# ╔═╡ a586a76c-7d87-11eb-3d5a-532dabe16cd0
all(isfinite.(sin_ν_solver))

# ╔═╡ b365405a-7d87-11eb-3d09-2ff43daad608
all(isfinite.(cos_ν_solver))

# ╔═╡ 53101446-7e0c-11eb-2b7f-d9c38e07e16f
eccs

# ╔═╡ b4ed0446-7d76-11eb-3506-4552b1f0f11a
begin
	py"""
	import numpy as np
	"""
	const allclose = py"np.allclose"
end

# ╔═╡ db4c082a-7d7c-11eb-366f-6da594876c0c
E_solver, E_user, allclose(E_solver, E_user)

# ╔═╡ 715065fc-7d80-11eb-0be1-adc0b76315db
sin_ν_solver, sin_ν_user, allclose(sin_ν_solver, sin_ν_user)

# ╔═╡ 762dcf88-7d80-11eb-39eb-fb295bf968d1
cos_ν_solver, cos_ν_user, allclose(cos_ν_solver, cos_ν_user)

# ╔═╡ Cell order:
# ╠═12d523ae-7b24-11eb-3e11-5581a47e1b90
# ╠═3893efb6-7d6e-11eb-32bb-1bfcc375b17d
# ╠═f6705594-7d6c-11eb-3624-53324bb04681
# ╠═75d06d62-7d73-11eb-3db7-97c3cbaebdb9
# ╟─e396ab44-7d2b-11eb-2f91-7573ef462559
# ╠═132e3b14-7d78-11eb-3591-bb0f1288b88e
# ╠═44c8b5ac-7d6c-11eb-17c5-5f22ffe3e385
# ╠═318c1376-7e0c-11eb-23ed-d14627a8c653
# ╠═318c7c6c-7e0c-11eb-16e9-9b70f4571225
# ╠═31077a28-7d7e-11eb-340c-77db01116fc1
# ╠═a586a76c-7d87-11eb-3d5a-532dabe16cd0
# ╠═b365405a-7d87-11eb-3d09-2ff43daad608
# ╠═53101446-7e0c-11eb-2b7f-d9c38e07e16f
# ╠═db4c082a-7d7c-11eb-366f-6da594876c0c
# ╠═715065fc-7d80-11eb-0be1-adc0b76315db
# ╠═762dcf88-7d80-11eb-39eb-fb295bf968d1
# ╠═b4ed0446-7d76-11eb-3506-4552b1f0f11a
