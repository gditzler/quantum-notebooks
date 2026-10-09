### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ cb9385a2-e038-47b9-9f9f-e022d1eebf0c
begin
	# Use the repo-root Project.toml instead of Pluto's per-notebook package manager.
	import Pkg
	Pkg.activate(Base.current_project(@__DIR__))
	using Yao
end

# ╔═╡ ac5eddb2-39f8-466f-8da1-0c97b358e40e
md"""
# 00 · Bell state

Prepare ``|\Phi^+\rangle = (|00\rangle + |11\rangle)/\sqrt{2}`` with H then CNOT, and sample it.
"""

# ╔═╡ 8e0d29df-ef40-40f2-bf55-0faaa18e6f38
bell = chain(2, put(1 => H), control(1, 2 => X))

# ╔═╡ f1ec94a8-1949-43c7-8f2f-b4226048328d
ψ = zero_state(2) |> bell

# ╔═╡ fc0b9fd7-ce74-4b52-9be1-3952240b882b
statevec(ψ)

# ╔═╡ f3d1e381-bf1d-4861-8da7-c952387dc8fb
samples = measure(ψ; nshots=1000)

# ╔═╡ b8e8fefa-74cf-4f94-9763-af6d74823dfe
Dict(s => count(==(s), samples) for s in unique(samples))

# ╔═╡ Cell order:
# ╟─ac5eddb2-39f8-466f-8da1-0c97b358e40e
# ╠═cb9385a2-e038-47b9-9f9f-e022d1eebf0c
# ╠═8e0d29df-ef40-40f2-bf55-0faaa18e6f38
# ╠═f1ec94a8-1949-43c7-8f2f-b4226048328d
# ╠═fc0b9fd7-ce74-4b52-9be1-3952240b882b
# ╠═f3d1e381-bf1d-4861-8da7-c952387dc8fb
# ╠═b8e8fefa-74cf-4f94-9763-af6d74823dfe
