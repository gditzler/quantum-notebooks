# Agent guide

- Python and Julia share the repo root: `pyproject.toml` (uv) and `Project.toml` (Julia).
- Python notebooks (`.ipynb`) go in `notebooks/python/`; Julia notebooks are Pluto `.jl` files in `notebooks/julia/`.
- Notebook naming: `NN-topic.ipynb` / `NN-topic.jl` (e.g. `00-bell-state`).
- Pluto notebooks activate the root env in a cell: `import Pkg; Pkg.activate(Base.current_project(@__DIR__))`. Don't use Pluto's embedded package manager.
- Add Python deps with `uv add`; Julia deps with `julia --project=. -e 'using Pkg; Pkg.add("X")'`. Commit `uv.lock` and `Manifest.toml`.
- Verify a Python notebook with `uv run jupyter nbconvert --to notebook --execute --stdout <nb>`.
- Verify a Pluto notebook by opening it with `Pluto.SessionActions.open(session, path; run_async=false)` and checking no cell has `errored`.
