# DegreeLabeling

DegreeLabeling formalises the source problem's two labelling results for finite simple
undirected graphs. T1 says that, for any strictly increasing real weights with no positivity
assumption, some degree-respecting bijective labelling orders equal-degree vertices so their
weighted neighbour sums are non-decreasing in the reverse label order. T2 is the original
powers-of-two corollary, using the source expression \(2^{f(u)}\). The primary source is [P]
in `sources/problem.md`; its digest and the decided `Fin n` label shift are in
`docs/math/degree_labeling.md`.

## Layout

| Path | Role |
|---|---|
| `DegreeLabeling/`, `DegreeLabeling.lean` | Lean module tree and root aggregator |
| `scripts/` | preflight, bootstrap, the canonical gate `check.sh`, integrity guards, GitHub setup, git hooks |
| `scripts/print_axioms.lean` | append-only list of pinned public theorems for the live axiom audit |
| `.claude/skills/` | scaffold procedure, project orchestration contract, decomposition and review-routing skills |
| `.claude/hooks/`, `.claude/settings.json` | SessionStart brief; PreToolUse guard that serialises Lean builds and enforces the codex kill switch |
| `.github/` | CI job `check`, Issue templates (formalization / infrastructure), PR template |
| `docs/orchestration.md` | the minimal role, configuration and lifecycle guide |
| `docs/adr/` | founding decisions: harness-driven, no state machine (0001); autonomous merge authority (0002) |
| `docs/math/` | references and the source-grounded mathematical digest |

## Results

The public theorems are `DegreeLabeling.exists_degreeOrdered_labeling_strictMonoWeights`
and `DegreeLabeling.exists_degreeOrdered_labeling_powersOfTwo`. T1 allows arbitrary
strictly increasing real weights, with no positivity assumption; T2 is the literal
real-valued, one-based powers-of-two specialization.

See [`DegreeLabeling.lean`](DegreeLabeling.lean),
[`DegreeLabeling/Contract.lean`](DegreeLabeling/Contract.lean), and
[`docs/math/degree_labeling.md`](docs/math/degree_labeling.md). Release evidence:
`CHECK OK`; 8 pinned public theorems; axiom closure within
`{propext, Classical.choice, Quot.sound}`; final source↔Lean fidelity verdict `PASS`
on charter Issue #1.

## Build

```sh
scripts/bootstrap.sh   # shared mathlib oleans and git hooks
scripts/check.sh       # guards → lake build → live #print axioms audit → coverage guard
```

The toolchain is `lean-toolchain`; mathlib remains pinned by tag in `lakefile.toml` and by
commit in `lake-manifest.json`. CI runs the textual guards and the full gate under the
repository's pull-request rules.

## Trust footprint

Accepted theorems are `sorry`-free and their axiom closure is contained in
`{propext, Classical.choice, Quot.sound}`; `scripts/check-axioms.sh` verifies this live for
every declaration listed in `scripts/print_axioms.lean`; the coverage guard fails the gate if
a public theorem is not listed.

## Workflow

GitHub Issues and pull requests are the only work queue and evidence record:
Issue → branch → PR → independent review → CI → squash merge. See
[docs/orchestration.md](docs/orchestration.md) for roles, configurations and lifecycle.
No status, roadmap or progress files are tracked; agent scratch lives in `.claude/scratch/`.

## License

Apache-2.0, see `LICENSE`.
