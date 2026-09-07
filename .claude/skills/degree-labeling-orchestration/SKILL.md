---
name: degree-labeling-orchestration
description: Container contract for the uda-lab/degree-labeling formalisation loop — tiers, vendor mapping, fan-out caps, exact worker/reviewer invocations, memory rules, kill switch, escalation boundary. Load first in every orchestrator session on this repository.
---

# DegreeLabeling orchestration (this container)

Companion to `loop-orchestration-scaffold` (procedure), `github-loop-engineering` (outer
loop) and `github-driven-workflow` (per-PR gate). Only what is specific to **this
repository and this machine**.

## Repository facts

- Repo `uda-lab/degree-labeling` (renamed from `lean-dogfood-codex`; unifies the parallel
  `lean-dogfood-claude` dogfood tree per #21), default branch `main`, ruleset: PR required,
  squash only, required check `check`.
- Identity `uda-lab-agent`, permissions `admin`. Owner-only actions (escalate, never attempt):
  visibility, rulesets, secrets, mathlib pin, budget.
- Merge authority: ADR 0002 granted. Merge command: bare `gh pr merge <N> --squash`.
- Charter Issue #1; mathematical SoT `docs/math/degree_labeling.md`.

## Configuration

This repository runs **mixed Claude+Codex orchestration** (owner directive, superseding any
single-vendor configuration from before the #21 unification):

| tier | resolved model | vendor |
|---|---|---|
| routine | Sonnet-class | Claude |
| reasoning | Opus-class (Fable where available) | Claude |

| role | who | tier | notes |
|---|---|---|---|
| orchestrator | interactive session (Claude or Codex) | reasoning | event-driven; tick ~1 h backstop |
| driver | the orchestrator session, or an `Agent`/`codex exec` subagent | routine (reasoning only with the reason on the Issue) | one per Issue, disposable; owns worktree, compile loop, PR, merge |
| worker | sonnet-class Claude by default (owner directive); the driver itself for small blocks | routine; reasoning for a hard first draft | ≤ 400 Lean lines/job |
| reviewer (PR) | broker, kind **`codex`, always** (Copilot retired 2026-06) | — | `python3 "$REVIEW_ACQUIRE_SCRIPT" uda-lab/degree-labeling <PR> codex` |
| reviewer (local) | read-only subagent distinct from the implementer | reasoning | numbered falsifiable risks, per `lean-review-routing` |
| judge | read-only subagent | reasoning | `sot-integrity`, `math-semantic-preservation` for the digest and fidelity audits |

Fan-out caps: one driver per lane, one lane; no fleets, no parallel review panels.

## Exact invocations

- Worker: sonnet-class Claude `Agent` dispatch, cwd = worktree, foreground; reap side
  processes on completion. A `codex exec -C <worktree> --sandbox danger-full-access ...` worker
  remains available for Codex-driven lanes but is no longer the default.
- Local review: a read-only reasoning-tier dispatch (Claude Opus/Fable, or
  `codex exec --sandbox read-only`), the numbered-risks prompt from `lean-review-routing`.
- PR review: `python3 "$REVIEW_ACQUIRE_SCRIPT" uda-lab/degree-labeling <PR> codex` — invoke
  verbatim; never copy, relocate, unset or self-point `REVIEW_ACQUIRE_SCRIPT`. 300 s cooldown
  between requests on one PR is not an error. A `chatgpt-codex-connector[bot]` "create a Codex
  account" reply is a canned response, not a route failure.
- Kill switch: `echo "<reason>" > /tmp/codex-stop` (enforced by `.claude/hooks/lean-guard.sh`);
  `rm /tmp/codex-stop` lifts it. Applies to Codex worker/driver processes; a stalled Claude
  agent is stopped via `TaskStop` / re-dispatch instead.

## Machine limits (measured)

- Memory cap 3.42 GiB (`memory.max` = 3670016000), no swap. `LEAN_GUARD_MIN_AVAIL_MIB=1024`,
  `LEAN_NUM_THREADS=2` (in the untracked `.claude/settings.local.json`; the guard's default
  1536 MiB is above what this box has free). `exit 137` = OOM; confirm in
  `/sys/fs/cgroup/memory.events`.
- Package oleans shared by `cp -al` from `/workspaces/mobius-cpt/.lake/packages` (same mathlib
  pin) or from another fully-built sibling clone with an identical `lean-toolchain`/
  `lakefile.toml` pin; never hardlink `.lake/build`; never cold-build mathlib.
- Build lock `/tmp/lean-build.lock` is container-wide, shared with every other repository on
  this machine; runs are sequential — never start a build while another repository's gate is
  running, and do not investigate the holder.
- Worktrees under `/workspaces/worktrees/<slug>`; install the guard there with
  `bash .claude/hooks/install.sh <path>` if the harness does not read `.claude/settings.json`
  from the worktree.
- Lean cannot run in the Codex sandbox on this machine. Any Codex process that may run Lean
  must use `--sandbox danger-full-access`; the devcontainer is the permitted outer boundary.

## Quotas

Mixed vendor usage: Claude sessions/subagents for orchestration, driving and default worker
duty; Codex used both as the PR-review broker (`codex` kind, always) and, on Codex-driven
lanes, as an alternate worker/local-reviewer route. No pay-as-you-go spending on either vendor
without owner authorisation.

## Escalation boundary

Channel: charter Issue #1 (no Discord, no owner ping unless the dispatching session is
Discord-driven). Escalate only: a destructive or irreversible action; a financial commitment; a
fatal mathematical error or gap; an owner-only action (visibility, rulesets, secrets, mathlib
pin, budget). Everything else is decided and recorded on the Issue.

## Dispatch-prompt checklist

`references/dispatch-prompt.md` of `loop-orchestration-scaffold`, every placeholder filled,
plus these repository traps learned so far:

- The `Fin n` source-label shift, the exact T2 exponent `f(u).val + 1`, empty graphs, no
  positivity assumption, the S2 finite minimisation domain, S4 edge bookkeeping, the shared
  build lock, and the sandbox-disabled requirement (see `docs/math/degree_labeling.md`).
- `scripts/rename-project.sh` substitutes the library name by whole word everywhere it
  appears, including comments and hook scripts describing the *uninitialised* scaffold; the
  prose still needs a hand rewrite afterwards.
- `scripts/check-transient-artifacts.sh` rejects tracked files whose stem contains `status`,
  `roadmap`, `todo`, `checklist`, `progress`, `handoff`, `worklog`, `ledger`, `activity-log`,
  `agent-log` or `completion`.
- `.claude/ENVIRONMENT.md` and `sources/` are untracked; copy facts from them into tracked
  policy text, never cite them as tracked paths.
- `AGENTS.md` stays 20–30 visible lines; `CLAUDE.md` stays a symlink to it, never a file.
