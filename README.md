# quantum-notebooks

Notebooks for learning quantum computing and quantum information science, in Python and Julia.

## Layout

```
quantum-notebooks/
├── pyproject.toml / uv.lock / .python-version   # Python env (uv)
├── Project.toml / Manifest.toml                  # Julia env
├── notebooks/
│   ├── python/        # Qiskit, QuTiP, NumPy
│   └── julia/         # Yao.jl, QuantumOptics.jl
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
uv run jupyter lab
```

Pick the **Python 3** kernel for `notebooks/python/` and **Julia quantum-notebooks** for `notebooks/julia/`.

## Adding packages

```sh
uv add <pkg>                                   # Python
julia --project=. -e 'using Pkg; Pkg.add("<Pkg>")'  # Julia
```
