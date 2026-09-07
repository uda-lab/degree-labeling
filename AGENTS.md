# Agent Guidelines

<!-- Do not restructure or delete sections. Update individual values in-place when they change. -->

## Core Principles

- Keep this file under 20-30 lines of visible guidance.
- Keep only repo-specific, non-obvious instructions here.

## Project Overview

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- `DegreeLabeling` formalises `[P]` (`docs/math/references.md`): for every finite simple graph there exists a degree-respecting labelling (smaller degree gets the larger label) that among same-degree vertices orders labels by a weighted neighbour-sum tie-break — T1 for a general strictly increasing weight, T2 (the original problem) for the source's `2^f(u)` weight. The mathematical source of truth is `docs/math/degree_labeling.md`; its conventions are frozen by the statement-contract history, not amended here.
- Charter Issue #1 tracks scope, milestones and the definition of done; `docs/orchestration.md` maps the orchestrator/driver/worker/reviewer/judge roles, and `.claude/skills/degree-labeling-orchestration/SKILL.md` is this machine's container contract.

## Commands

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
~~~sh
scripts/preflight.sh      # measured environment facts; no build, no GitHub mutation
scripts/bootstrap.sh      # idempotent: mathlib oleans + git hooks path; never cold-build mathlib, never `lake update`
scripts/check.sh          # full gate: guards, lake build, live #print axioms, coverage; serialised on /tmp/lean-build.lock
scripts/github-setup.sh   # idempotent labels, squash-only, `main` ruleset
~~~

## Code Conventions

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- Accepted code has no `sorry`/`admit`; `-- ALLOW_SORRY: #<issue> …` on the same line is the only escape, for work an Issue authorises to land incomplete, and it never reaches a pinned theorem's closure.
- No `axiom`/`constant`/`opaque`/`unsafe`; `-- ALLOW_AXIOM: #<issue> …` passes the textual guard but `scripts/check-axioms.sh` still rejects it (allowlist: propext, Classical.choice, Quot.sound; changing it is `needs-decision`).
- Never weaken, specialise or trivialise a statement to close a proof; statement-changing PRs need a source ↔ Lean review by an agent distinct from the implementer.
- Every public theorem a PR claims is appended to `scripts/print_axioms.lean` (append-only; enforced by the coverage guard).
- Proof experiments, logs, plans and notes stay untracked (`.claude/scratch/`); the transient-artefact guard rejects status/roadmap/handoff-style documents.

## Architecture

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- `DegreeLabeling/` module tree with root aggregator `DegreeLabeling.lean`; mathlib pinned by tag in `lakefile.toml` and by commit in `lake-manifest.json` (bumping is an infrastructure Issue).
- Flow: Issue → `issue-<n>-<slug>` branch → PR (`Closes #n`, no unchecked boxes) → independent review → CI job `check` → squash merge; no direct pushes to `main`.
- `agent:ready` is the execution-authorisation label, applied only by the owner or the trusted maintainer after auditing scope and acceptance; `blocked`, `needs-decision`, `do-not-merge` are hard stops.
- Durable decisions go to `docs/adr/`, mathematical statements to `docs/math/`; everything else lives in Issues and PRs. No orchestration runtime or state machine lives here (ADR 0001).

## Maintenance Notes

<!-- This section is permanent. Do not delete. -->
- Delete stale or inferable guidance.
- Update commands and architecture when workflows change.
- Keep durable rules here; move detail to dedicated docs.
