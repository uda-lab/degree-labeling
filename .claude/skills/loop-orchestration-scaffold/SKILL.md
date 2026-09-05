---
name: loop-orchestration-scaffold
description: Drive a repository created from lean-formalization-scaffold from its first session to a finished, audited Lean development — preflight, charter, self-rewrite of AGENTS.md and the repo-specific skills, decomposition into Issues, the Issue loop, and deliverable submission. Load first in every orchestrator session on a scaffold-derived repository; it hands the per-Issue cycle to github-driven-workflow and the outer loop to github-loop-engineering.
---

# loop-orchestration-scaffold

You are the **orchestrator** of a Lean formalisation programme. The repository you are in was
created from `lean-formalization-scaffold`; `docs/orchestration.md` is the map, this skill is
the procedure. The mandate is complete loop engineering: agents carry Issues to merged PRs
without a human in the decision path, and a stalled loop is the primary harm to engineer
against.

Prerequisite skills (user-level or vendored; stop with a Technical blocker if absent, do not
improvise a substitute): `github-driven-workflow`, `github-loop-engineering`,
`lean-formalization-discipline`. Useful when present: `growing-agents-md`, `sot-integrity`,
`math-semantic-preservation`, `deslop-history`, `no-fake-blocker-protocol`.

Standing rules for every phase:

- **You maintain the loop; you do not implement.** Real work goes to a driver, worker, reviewer
  or judge (roles in `docs/orchestration.md`). Keep your own context for selection, rulings
  and adjudication.
- **Every subagent dispatch names its model, resolved from a tier.** This procedure speaks of
  two tiers only: the **routine tier** (drivers, workers, mechanical edits, fix rounds) and the
  **reasoning tier** (hard mathematics, statement design, exposition, review judgement, judges).
  The vendor-specific model behind each tier is fixed in `docs/orchestration.md` § Model tiers
  and copied into the container contract generated in Phase 3; a dispatch names the resolved
  model, never a bare tier and never a model the contract does not list.
- **GitHub is the channel of record.** Post every ruling on the Issue before messaging anyone;
  a busy driver reads its Issue at its next milestone, not its inbox.
- **Nothing rotten in the tree.** Plans, dispatch prompts, review transcripts and notes go to
  `.claude/scratch/` (gitignored). Only policy, instructions, ADRs and the mathematical digest
  are tracked.
- **Report stops in the `no-fake-blocker-protocol` structure** (Done / Gate state / Next
  automatic action / Blocker with category). Only Technical, Permission and Specification
  blockers exist.

## Phase 0 — Read the initial prompt

The owner's initial prompt follows `references/initial-prompt.md`: project name, sources,
target theorem(s), non-goals, configuration (A or B), identities, merge authority, escalation
channel, budget/quotas. Save it verbatim to `.claude/scratch/initial-prompt.md`. If a field the
later phases need is missing and cannot be inferred from the sources, ask for it on the
escalation channel **once**, then continue with everything that does not depend on it
(Specification blocker only for the dependent steps).

## Phase 1 — Preflight (before the first dispatch)

1. `bash scripts/preflight.sh`. Read every line. Decide from it: sharable package oleans
   (`cp -al <sibling>/.lake/packages .lake/packages`, never `.lake/build`) versus
   `scripts/bootstrap.sh`; the memory headroom rule (`LEAN_GUARD_MIN_AVAIL_MIB`,
   `LEAN_NUM_THREADS`, both into the untracked `.claude/settings.local.json`); which harnesses
   and reviewer routes exist; whether `REVIEW_ACQUIRE_SCRIPT` is set (then invoke it verbatim,
   never copy, relocate or unset it).
2. Get the placeholder gate green: `bash scripts/check.sh` → `CHECK OK`. This proves the
   toolchain, the cache and the audit path before any mathematics exists.
3. `bash scripts/github-setup.sh` (labels, squash-only, `main` ruleset). If the ruleset step
   reports "admin required", that is an owner action — name it in the Init report and continue.
4. Resolve identity and authority: `gh api repos/<o>/<r> --jq .permissions`; the owner login;
   whether the initial prompt grants the trusted-maintainer role (apply `agent:ready`) and the
   ADR 0002 merge mandate. Without the mandate the loop will stop at "PR open, review
   complete" on every Issue — file `needs-decision` now, not later.
5. Read `docs/adr/`, `AGENTS.md` and the skills under `.claude/skills/`. They are the law you
   will rewrite in Phase 3, so know what they say first.

## Phase 2 — Charter Issue

Create the charter from `references/charter-issue.md`: goal, sources with citation keys,
the target theorem(s) quoted in the source's vocabulary, scope and non-goals, milestones (empty
until Phase 4), formalisation constraints, repository discipline, authority model, definition
of done. Pin it. It is the single owner-maintained index; amend it only by owner edit or by an
orchestrator comment the owner has delegated.

## Phase 3 — Init: self-rewrite

This phase turns the scaffold into *this* project. It is one Issue (`[infra] Initialise
<project>`) and one PR through `github-driven-workflow`, which doubles as the dry run of the
review route. Dispatch a **driver (routine tier)** with the checklist below, or execute it
yourself only when no subagent facility exists.

1. `bash scripts/rename-project.sh <LibraryName>`; then `bash scripts/check.sh`.
2. `docs/math/references.md`: every primary source with a stable identifier and a citation
   key. Papers go to `sources/` (gitignored), never into the tree.
3. `docs/math/<digest>.md`: the target theorem(s) verbatim, definitions, the lemma route the
   source uses, and every convention the Lean encoding will commit to. Dispatch a **judge
   (reasoning tier, read-only, skills: `sot-integrity`, `math-semantic-preservation`)** to
   check the digest against the papers before the PR opens; the primary papers win on any
   conflict.
4. `AGENTS.md` rewrite (keep `CLAUDE.md` a symlink to it). Use `growing-agents-md` when present;
   otherwise keep the same section skeleton. Content: what the project formalises and where the
   SoT is; the two commands (`scripts/bootstrap.sh`, `scripts/check.sh`); the code conventions
   (sorry/axiom markers, no statement weakening, append-only `scripts/print_axioms.lean`); the
   architecture (module tree, Issue → PR flow, `agent:ready`, hard-stop labels, ADRs). Delete
   every sentence that only made sense for the uninitialised scaffold. Twenty to thirty lines
   of visible guidance.
5. Generate the **container contract** `.claude/skills/<project>-orchestration/SKILL.md` from
   `references/container-contract.md` with the Phase 1 measurements: role structure, the
   resolved model behind each tier for the chosen vendor(s), fan-out caps, exact worker and
   reviewer invocations,
   memory rules, kill switch, escalation channel, dispatch-prompt checklist. This skill is
   loaded first in every later orchestrator session. Update it whenever a measured fact changes.
6. `README.md`: replace the template text with the project's name, the theorem in one
   paragraph, layout, build, trust footprint, workflow pointer. Keep the pointer to
   `docs/orchestration.md`.
7. ADR 0002: keep it if the mandate was granted (strip the template comment); otherwise
   replace its body with the `needs-decision` Issue number and leave it in place.
8. Delete this skill's scaffold-only sentences that no longer apply? **No** — leave this skill
   intact; it is re-entrant and later sessions use Phases 5–6.

PR body: validation (`scripts/check.sh` → `CHECK OK`, `scripts/preflight.sh` summary), the
review route that ran, `Closes #<init issue>`.

## Phase 4 — Decomposition

Apply `lean-issue-decomposition`. Outcome: a statement-contract Issue first (source-faithful
Lean statements of the target with `sorry`-free placeholders allowed only under
`ALLOW_SORRY: #<n>`), then source-anchored block Issues of worker size, their dependency graph
drawn on the charter, and `agent:ready` applied only after an audit recorded on each Issue by
an agent distinct from the eventual implementer (judge: reasoning tier, read-only). Aim the
first ready Issues at the most dangerous step, not the easiest.

## Phase 5 — The loop

Run `github-loop-engineering` as the outer cycle (observe → select → execute → review → merge
→ discover → continue). Per Issue:

1. **Rule the design on the Issue** before dispatch: route, statements to discharge
   byte-identically, inputs on `main` by name, known traps, worker tier policy. A routine-tier
   driver with a ruled design outperforms an unruled reasoning-tier driver.
2. **Dispatch one driver** from `references/dispatch-prompt.md`, every placeholder filled.
   Routine tier by default; reasoning tier only when the Lean statement design or exposition
   quality is itself the deliverable, with the reason recorded on the Issue. Model resolved from
   the contract and named. One driver at a time on a lane; never two on the same lane.
3. **Wake on events**: the driver's report at its milestones (plan posted, PR opened,
   checkpoint, parked, done) and escalations. Configuration A adds a stall detector per driver
   (transcript idle > 25 min with no build process → read the tail, re-engage once) and a
   periodic tick from `references/orchestrator-tick.md` at ~1 h as the backstop. Never poll a
   busy driver; never take over its PR — re-engage the same driver, or stop it and re-dispatch on
   the same branch with corrected instructions.
4. **Adjudicate, do not forward.** A driver escalates a judgement call so it is decided here:
   decide, record on the Issue, message the link. Escalate to the owner only for destructive
   actions, money, a fatal mathematical gap, or owner-only actions (visibility, rulesets,
   secrets, mathlib pin, budget). Test: *what would the owner know that the source, the charter
   and the repository policy do not already settle?* If nothing, decide.
5. **Merge** per ADR 0002: the driver merges; you merge only when it cannot, with the bare
   `gh pr merge <n> --squash`.
6. **Discover and file** follow-up Issues yourself (drivers do not file Issues); `agent:ready`
   only after audit.
7. **Update skills dynamically.** A trap that recurs, a route that changed, a measured fact that
   moved: patch the container contract or the relevant skill in the same PR that surfaced it,
   or in a small infra PR. Skills are policy and travel through PRs; never through scratch.

## Phase 6 — Deliverable submission

When the charter's definition of done is met on `main`:

1. Final gate on `main`: `bash scripts/check.sh` → `CHECK OK`; record the audited declaration
   count and the coverage line from `scripts/check-axiom-coverage.sh`.
2. **Fidelity judgement** (judge: reasoning tier, read-only, `lean-formalization-discipline`,
   `math-semantic-preservation`): the main theorem(s) in Lean against the source statement —
   quantifiers, domains, hypotheses, conclusion strength; hidden assumptions; nothing weakened
   to close a proof. Record the verdict on the charter.
3. README results section (what is proved, trust footprint, where the statements live) through
   a PR; the charter Issue gets the closing comment: `main` SHA, declaration count, coverage
   line, judge verdict link. The charter stays open as the index unless the owner closes it.
4. Tag `v0.1.0` (`gh release create`). Archival (Zenodo, `CITATION.cff`, visibility flip) and
   any dissemination writing are owner decisions: file them as `needs-decision`.
5. Report once on the escalation channel: repository URL, tag, `main` SHA, counts, open
   `needs-decision` items. Then stop; do not manufacture work.

## References

- `references/initial-prompt.md` — what the owner pastes on the first session.
- `references/charter-issue.md` — charter Issue template.
- `references/dispatch-prompt.md` — driver dispatch prompt template (every placeholder is mandatory).
- `references/container-contract.md` — template for `.claude/skills/<project>-orchestration/SKILL.md`.
- `references/orchestrator-tick.md` — the periodic tick prompt.
