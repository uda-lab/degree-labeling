---
name: degree-labeling-orchestration
description: Container contract for the uda-lab/lean-dogfood-codex formalisation loop — tiers, Codex mapping, one-lane cap, exact worker and reviewer invocations, memory rules, kill switch, and escalation boundary. Load first in every orchestrator session on this repository.
---

# DegreeLabeling orchestration (this container)

Companion to `loop-orchestration-scaffold` (procedure), `github-loop-engineering` (outer loop), and `github-driven-workflow` (per-PR gate); these are the repository- and machine-specific facts measured or decided on 2026-09-06.

## Repository facts

- Repo `uda-lab/lean-dogfood-codex`, default branch `main`; ruleset requires PRs, squash-only
  merges, and the `check` job.
- Identity `uda-lab-agent` with admin permissions; owner-only escalation boundaries are visibility, rulesets, secrets, mathlib pins, and budget.
- ADR 0002 grants merge authority after all gates pass. Use the bare command
  `gh pr merge <N> --squash`.
- Charter Issue #1; mathematical source of truth is `docs/math/degree_labeling.md`, with
  primary source `[P]` at `sources/problem.md`.

## Configuration B-codex

Model tiers resolved for this repository from `docs/orchestration.md`:

| tier | resolved model / effort | vendor |
|---|---|---|
| routine | `gpt-5.6-luna` at `xhigh` | Codex |
| reasoning | `gpt-5.6-sol` at `high` | Codex |

| role | who | tier | notes |
|---|---|---|---|
| orchestrator and driver | current Codex session | reasoning for rulings; routine worker jobs | one Issue at a time |
| worker | `codex exec` | routine | one foreground job, at most 400 Lean lines |
| reviewer (local) | `read-only codex exec` | reasoning | read-only adversarial review |
| reviewer (PR) | Hermes broker, kind `codex` | — | independent review evidence |
| judge | read-only `codex exec` | reasoning | source-fidelity judgement |

Fan-out cap: one lane; one driver per lane, no fleets, and no parallel review panels.

## Exact invocations

- Worker: `codex exec -C <worktree-or-repo> --sandbox danger-full-access -m gpt-5.6-luna -c model_reasoning_effort='"xhigh"' "<brief>"`.
- PR review: `python3 "$REVIEW_ACQUIRE_SCRIPT" uda-lab/lean-dogfood-codex <PR> codex`; with `REVIEW_ACQUIRE_SCRIPT=/workspaces/hermes-engineering/scripts/request-review.py`, invoke verbatim, and observe the expected 300 s cooldown between requests on one PR.
- Local review: `codex exec -C <worktree-or-repo> --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort='"high"' - < .claude/scratch/local-review-issue-{N}.md`. The prompt names numbered falsifiable risks and explicitly directs inspection of `git diff main...HEAD`.
- Reasoning read-only judge: `codex exec -C <worktree-or-repo> --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort='"high"' "<bounded judgement brief>"`.
- Kill switch: `echo "<reason>" > /tmp/codex-stop`; remove `/tmp/codex-stop` to lift it.

## Machine limits and build discipline

- Worktrees are under `/workspaces/worktrees/<slug>`; when the harness does not read the worktree settings, install the guard with `bash .claude/hooks/install.sh <path>`.
- Memory cap is 3.42 GiB with no container swap; require at least 1024 MiB before every Lean gate, with `LEAN_GUARD_MIN_AVAIL_MIB=1024` and `LEAN_NUM_THREADS=2`.
- Every Lean invocation holds the container-wide `/tmp/lean-build.lock`; `scripts/check.sh`
  takes it itself. Never start a second Lean process, use bare `lake build`, use `-M`/`-j`,
  or run `lake update`.
- Shared package oleans come from `/workspaces/mobius-cpt/.lake/packages` via `cp -al`; never hardlink `.lake/build` and never cold-build mathlib.
- Lean cannot run in the Codex sandbox on this machine. Any Codex process that may run Lean
  must use `--sandbox danger-full-access`; the devcontainer is the permitted outer boundary.

## Quotas and escalation

- Codex subscription only: no Claude sessions and no pay-as-you-go spending; at 100% of the Codex window, stop and report. The review cooldown is 300 s per PR, and parallel review requests are prohibited.
- Escalate only destructive or irreversible actions, financial commitments, fatal
  mathematical errors or gaps, and owner-only actions. Record ordinary rulings on the
  relevant GitHub Issue; the charter is Issue #1.

## Dispatch checklist

Use `references/dispatch-prompt.md` from `loop-orchestration-scaffold` with every placeholder
resolved. Read Issue comments before each block and review. Preserve the traps from Issue #2:
the `Fin n` source-label shift, the exact T2 exponent `f(u).val + 1`, empty graphs, no
positivity assumption, the S2 finite minimisation domain, S4 edge bookkeeping, the shared
build lock, and the sandbox-disabled requirement.
