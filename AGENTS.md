# Agent Guidelines

<!-- Do not restructure or delete sections. Update individual values in-place when they change. -->

## Core Principles

- Keep this file under 20-30 lines of visible guidance.
- Keep only repo-specific, non-obvious instructions here.

## Project Overview

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- DegreeLabeling formalises T1 (strictly increasing weights) and T2 (powers of two) from primary source [P].
- `docs/math/degree_labeling.md` is the mathematical digest; `sources/problem.md` is the ignored primary input.
- Labels use `Fin n` with source label `f(v).val + 1`; empty and edgeless graphs remain in scope.

## Commands

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
~~~sh
scripts/bootstrap.sh   # shared mathlib oleans and hooks
scripts/check.sh       # full integrity, build, axiom and coverage gate
~~~

## Code Conventions

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- Accepted code has no `sorry`/`admit`; `ALLOW_SORRY: #<issue> …` is the only authorised temporary exception.
- No project `axiom`/`constant`/`opaque`/`unsafe`; allowed kernel axioms remain `{propext, Classical.choice, Quot.sound}`.
- Never weaken, specialise or trivialise a source statement; statement changes require independent source ↔ Lean review.
- Append every claimed public theorem to `scripts/print_axioms.lean`; the coverage guard is append-only.
- Keep proof experiments, logs and dispatch notes untracked under `.claude/scratch/`.

## Architecture

<!-- Managed section: update with apply input, or omit/pass [] to remove. -->
- `DegreeLabeling/` is the module tree and `DegreeLabeling.lean` is its root aggregator; mathlib pins stay fixed.
- Flow is Issue → `issue-<n>-<slug>` branch → PR (`Closes #n`) → independent review → CI `check` → squash merge.
- One Issue runs per lane; `agent:ready` requires owner or trusted-maintainer audit, while `blocked`, `needs-decision` and `do-not-merge` stop work.
- Durable decisions live in `docs/adr/`, mathematical statements in `docs/math/`, and every orchestration session, including Codex, must read `.claude/skills/degree-labeling-orchestration/SKILL.md` first.
- GitHub Issues and PRs are the queue and evidence surface; no local orchestration runtime or state machine is tracked.

## Maintenance Notes

<!-- This section is permanent. Do not delete. -->
- Delete stale or inferable guidance.
- Update commands and architecture when workflows change.
- Keep durable rules here; move detail to dedicated docs.
