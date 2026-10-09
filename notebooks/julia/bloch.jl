### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ 9f40adf0-c424-11f1-b666-31f6a68b1125
using LinearAlgebra, Random, Test

# ╔═╡ 117dd564-20e9-4ce8-bbca-1e3d79c21df3
md"""
# N&C Ch.1 §1.2 — Exercise 1: Bloch map and the Poincaré sphere

Write `ket(θ, φ)` implementing N&C eq. 1.4, |ψ⟩ = cos(θ/2)|0⟩ + e^{iφ} sin(θ/2)|1⟩. Also write `bloch(ψ)`, which returns (⟨X⟩, ⟨Y⟩, ⟨Z⟩).

- Verify the round trip on 10⁴ random (θ, φ).
- Show that `bloch(exp(im*α) * ψ)` is independent of α. Global phase is physically invisible.
- Draw states as normalize(randn(ComplexF64, 2)) and confirm ‖r‖ = 1. Pure states live on the surface of the sphere.
- RF lens (exact): A Jones vector (E_h, E_v) is a normalized complex 2-vector, so it is a qubit. Its Stokes vector is the Bloch vector, up to an axis relabeling. Map H, V, ±45° linear, RHCP, and LHCP to Bloch points. You’ll find that orthogonal polarizations sit antipodally. This is the source of the factor of 2 in θ/2: orthogonal states are 180° apart on the sphere, not 90°.

"""

# ╔═╡ 42af3812-efe4-40e2-aed7-3bbabe5524e4
begin
	const ket0 = ComplexF64[1, 0]
	const ket1 = ComplexF64[0, 1]
	const X  = ComplexF64[0 1; 1 0]
	const Y  = ComplexF64[0 -im; im 0]
	const Z  = ComplexF64[1 0; 0 -1]
	 
	samephase(a, b; atol=1e-10) = isapprox(abs(dot(a, b)), 1; atol)
end

# ╔═╡ 837d5792-0d36-4c0a-b28e-742b50c3ed05
ket(θ::Real, ϕ::Real) = cos(θ/2) * ket0 + cis(ϕ) * sin(θ/2) * ket1  

# ╔═╡ fe256520-1970-4cbc-98de-aec9d433c6a9
begin
	expect(A, ψ) = real(dot(ψ, A * ψ)) # dot conjugates the first arg: ψ†Aψ
	bloch(ψ) = [expect(X, ψ), expect(Y, ψ), expect(Z, ψ)]
	 
	# Closed form, useful as a cross-check: with ψ = (α, β),
	#   x + iy = 2 conj(α) β,   z = |α|² − |β|²
	bloch_closed(ψ) = (c = 2conj(ψ[1])*ψ[2]; [real(c), imag(c), abs2(ψ[1]) - abs2(ψ[2])])
end

# ╔═╡ a4e40da0-86bc-4afe-9f13-3b476e2a29cf
function angles(ψ)
    x, y, z = bloch(ψ)
    θ = acos(clamp(z, -1, 1))                 # clamp guards against z = 1 + 1e-16
    ϕ = mod(atan(y, x), 2π)                   # undefined at the poles; atan(0,0) = 0
    return θ, ϕ
end


# ╔═╡ bc0695a8-a692-41ff-83b6-fdd8f055393a
begin
	Random.seed!(1)
    N = 10_000
 
    @testset "Ex 1: Bloch sphere" begin
        @testset "normalization of ket(θ,ϕ)" begin
            @test all(norm(ket(π*rand(), 2π*rand())) ≈ 1 for _ in 1:N)
        end
     
        @testset "bloch(ket(θ,ϕ)) = (sinθ cosϕ, sinθ sinϕ, cosθ)" begin
            for _ in 1:N
                θ, ϕ = π*rand(), 2π*rand()
                @test bloch(ket(θ, ϕ)) ≈ [sin(θ)cos(ϕ), sin(θ)sin(ϕ), cos(θ)] atol=1e-12
            end
        end
     
        @testset "round trip (θ,ϕ) → ψ → (θ̂,ϕ̂) → ψ̂" begin
            # Compare *states* up to phase, not angles: avoids 2π wrap and the
            # pole degeneracy (ϕ is meaningless at θ ∈ {0, π}).
            for _ in 1:N
                ψ = ket(π*rand(), 2π*rand())
                @test samephase(ket(angles(ψ)...), ψ)
            end
            @test samephase(ket(angles(ket0)...), ket0)   # poles explicitly
            @test samephase(ket(angles(ket1)...), ket1)
        end
     
        @testset "global phase is invisible" begin
            for _ in 1:1000
                ψ = normalize(randn(ComplexF64, 2))
                @test bloch(cis(2π*rand()) * ψ) ≈ bloch(ψ) atol=1e-12
            end
        end
     
        @testset "random pure states lie on the surface" begin
            for _ in 1:N
                ψ = normalize(randn(ComplexF64, 2))
                @test norm(bloch(ψ)) ≈ 1
                @test bloch(ψ) ≈ bloch_closed(ψ)
            end
        end
     
        @testset "overlap ↔ Bloch angle:  |⟨a|b⟩|² = (1 + rₐ·r_b)/2" begin
            for _ in 1:N
                a, b = normalize(randn(ComplexF64, 2)), normalize(randn(ComplexF64, 2))
                @test abs2(dot(a, b)) ≈ (1 + dot(bloch(a), bloch(b))) / 2
            end
        end
    end
end

# ╔═╡ 6cb4fbac-6d2e-49e2-a60f-a611c3005a38
begin
	# Basis convention: |0⟩ = ĥ (horizontal), |1⟩ = v̂ (vertical).
    # Normalized Stokes parameters of a Jones vector E = (E_h, E_v):
    stokes(E) = [abs2(E[1]) - abs2(E[2]),        # S1: H vs V
                 2real(conj(E[1]) * E[2]),       # S2: +45° vs −45°
                 2imag(conj(E[1]) * E[2])]       # S3: circular (sign = convention!)
     
    # Relabeling: (S1, S2, S3) = (z, x, y)
    @testset "Stokes is a permuted Bloch vector" begin
        for _ in 1:N
            E = normalize(randn(ComplexF64, 2))
            x, y, z = bloch(E)
            @test stokes(E) ≈ [z, x, y]
        end
    end
     
    # Engineering time convention e^{jωt}: (ĥ − j v̂)/√2 is RHCP (IEEE definition).
    # In the physics convention e^{−iωt}, the same field is (ĥ + i v̂)/√2.
    pols = [
        "H"           => ComplexF64[1, 0],
        "V"           => ComplexF64[0, 1],
        "+45°"        => ComplexF64[1, 1] / √2,
        "−45°"        => ComplexF64[1, -1] / √2,
        "RHCP (IEEE)" => ComplexF64[1, -im] / √2,
        "LHCP (IEEE)" => ComplexF64[1, im] / √2,
    ]
     
    println("\npolarization   Bloch (x, y, z)          Stokes (S1, S2, S3)")
    for (name, E) in pols
        r, s = round.(bloch(E); digits=3) .+ 0.0, round.(stokes(E); digits=3) .+ 0.0
        println(rpad(name, 15), rpad(string(r), 25), s)
    end
     
    println("\northogonal pairs: ⟨a|b⟩ and the Bloch-sphere angle between them")
    for (a, b) in [(1, 2), (3, 4), (5, 6)]
        (na, Ea), (nb, Eb) = pols[a], pols[b]
        ang = rad2deg(acos(clamp(dot(bloch(Ea), bloch(Eb)), -1, 1)))
        println(rpad("$na vs $nb", 28), "|⟨a|b⟩| = ", abs(dot(Ea, Eb)), "   angle = ", round(ang), "°")
    end
     
    # The bug in the first draft: an extra /2 on the |0⟩ amplitude.
    ket_bug(θ, ϕ) = cos(θ/2)/2 * ket0 + cis(ϕ) * sin(θ/2) * ket1
    println("\nbuggy ket: norm at θ = 0 → ", norm(ket_bug(0, 0)),
            ",  at θ = π/2 → ", round(norm(ket_bug(π/2, 0)); digits=4))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.1"
manifest_format = "2.1"
project_hash = "efdbf0ab7c4cbd0face147f59306e60819a18a28"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╟─117dd564-20e9-4ce8-bbca-1e3d79c21df3
# ╠═9f40adf0-c424-11f1-b666-31f6a68b1125
# ╠═42af3812-efe4-40e2-aed7-3bbabe5524e4
# ╠═837d5792-0d36-4c0a-b28e-742b50c3ed05
# ╠═fe256520-1970-4cbc-98de-aec9d433c6a9
# ╠═a4e40da0-86bc-4afe-9f13-3b476e2a29cf
# ╠═bc0695a8-a692-41ff-83b6-fdd8f055393a
# ╠═6cb4fbac-6d2e-49e2-a60f-a611c3005a38
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
