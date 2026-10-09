# Agent guide

- Python and Julia share the repo root: `pyproject.toml` (uv) and `Project.toml` (Julia).
- Python notebooks go in `notebooks/python/`, Julia notebooks in `notebooks/julia/`.
- Notebook naming: `NN-topic.ipynb` (e.g. `00-bell-state.ipynb`).
- Add Python deps with `uv add`; Julia deps with `julia --project=. -e 'using Pkg; Pkg.add("X")'`. Commit `uv.lock` and `Manifest.toml`.
- Julia notebooks use the `julia-quantum-notebooks` kernel (`--project=@.`).
- Verify a notebook with `uv run jupyter nbconvert --to notebook --execute --stdout <nb>`.
