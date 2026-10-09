# quantum-notebooks

Notebooks for learning quantum computing and quantum information science, in Python and Julia.

## Layout

```
quantum-notebooks/
├── pyproject.toml / uv.lock / .python-version   # Python env (uv)
├── Project.toml / Manifest.toml                  # Julia env
├── notebooks/
│   ├── python/        # Qiskit, QuTiP, NumPy
│   └── julia/         # Pluto notebooks (.jl): Yao.jl, QuantumOptics.jl
└── data/              # local data, git-ignored
```

Both languages share the repo root: each tool only reads its own manifest
(`pyproject.toml` vs `Project.toml`), so they never collide.

## Setup

```sh
# Python (also provides JupyterLab for both languages)
uv sync

# Julia
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. -e 'using IJulia; IJulia.installkernel("Julia quantum-notebooks", "--project=@."; specname="julia-quantum-notebooks")'
```

The Julia kernel uses `--project=@.`, which searches upward from the notebook's
folder and finds the root `Project.toml`.

## Run

```sh
# Python notebooks
uv run jupyter lab

# Julia (Pluto) notebooks
julia --project=. -e 'using Pluto; Pluto.run()'
```

Pluto notebooks are plain `.jl` files. Each one activates the repo-root
`Project.toml` in its first code cell (`Pkg.activate(Base.current_project(@__DIR__))`),
so they share the project's packages instead of Pluto's per-notebook package manager.
The IJulia kernel is still available if you want a Julia notebook in Jupyter.

## Adding packages

```sh
uv add <pkg>                                   # Python
julia --project=. -e 'using Pkg; Pkg.add("<Pkg>")'  # Julia
```
