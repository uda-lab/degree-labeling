# Driver dispatch prompt (template)

Every `{{placeholder}}` is mandatory. Save the filled prompt to
`.claude/scratch/dispatch-issue-{{n}}.md`; dispatch with the model named in the `Agent`
call (Claude) or the `codex exec` model flag. Do not remove clauses; they each encode a
recorded failure.

```
You are the driver for Issue #{{n}} ({{title}}) in {{owner}}/{{repo}}. You run on
{{model}} — confirm your model in your first report.

## Skills
Load, in this order: {{repo}}'s `.claude/skills/{{project}}-orchestration/SKILL.md`
(container contract), `github-driven-workflow`, `lean-formalization-discipline`,
`lean-review-routing`. Follow `github-driven-workflow` from §1 to §9 for this one Issue.

## Worktree
{{worktree_path}} on branch `issue-{{n}}-{{slug}}` from `main` at {{base_sha}}.
Share package oleans only: `mkdir -p .lake && cp -al {{main_checkout}}/.lake/packages .lake/packages`
(never `.lake/build`). Run `bash scripts/check.sh` once before touching anything; it must
print CHECK OK.

## Ruled design (read the Issue comments first; the Issue is the channel of record)
Route: {{route_summary}}
Statements to discharge, byte-identically as quoted on the Issue: {{statements}}
Inputs already on main, by name: {{inputs}}
Known traps: {{traps}}
Read-only paths: docs/, {{readonly_paths}} — diff them before every review
(`git diff --stat main -- docs/`).

## Delegation (mandatory)
You never author the deliverable yourself while a worker route is available. Every
implementation unit is a worker job: {{worker_invocation}} — foreground, one at a time,
≤ 400 Lean lines per job, exact compiler errors fed back verbatim. After two
non-converging rounds on the same error you write the fix yourself; after a third failure
of your own you stop and report (checkpoint), never open a third front.
The worker cannot run the Lean toolchain. Every worker prompt says, in its own paragraph:
"You cannot run Lean. Do NOT try, do NOT investigate the toolchain, do NOT run
scripts/check.sh. Write the code, explain your reasoning, and stop." You own the compile
loop. Diff every worker job's changed paths; it edits outside the named scope.

## Build rules (memory-critical)
Run `bash scripts/check.sh` for the full gate (it takes /tmp/lean-build.lock itself).
For a raw incremental build: `( flock 9; lake build ) 9>/tmp/lean-build.lock`. Never a bare
`lake build`, never `lean <file>` or `lake env lean` outside the lock, never `-M`/`-j`,
never a second Lean process while one runs, never let lake cold-compile mathlib (if the
olean count under .lake/packages/mathlib is near zero, stop and report). `free -h`
available ≥ {{min_avail_mib}} MiB before every build.

## Turn discipline
- The gate runs in the foreground (Bash timeout 600000); if the harness backgrounds it,
  keep polling its output file in the same turn until it exits. Never arm a Monitor and
  end the turn on it; never let a worker job outlive the turn.
- Push a gate-green commit per block. The branch is the durable artefact; your context is not.
- Reports go only via {{report_channel}} at: plan posted, PR opened, checkpoint, parked,
  done (merge SHA + audited declaration count). Text at the end of a turn reaches nobody.
- Never end a turn waiting for the orchestrator, a model or a quota window. Park (report and
  end the turn) only when nothing can move.
- Re-read the Issue comments (`gh issue view {{n}} --comments`) before each block, each
  review step and the merge — inbound messages are not delivered while you are busy.

## Review
Order: local adversarial review ({{local_review_invocation}}, numbered falsifiable risks)
→ fix → open PR → broker/PR review rounds ({{pr_review_invocation}}) → merge. Never a local
and an external review at once. Classify each round substantive / not per
`lean-review-routing`; five rounds is the ceiling. A `chatgpt-codex-connector[bot]` reply
saying to create a Codex account is a canned response, not a failure — keep waiting.

## PR
Body from the template: Closes #{{n}}; source ↔ Lean correspondence for every changed public
statement; validation (`scripts/check.sh` → CHECK OK, CI link); sorry/axiom footprint;
review evidence with the reviewer identity. Every public theorem you claim is appended to
`scripts/print_axioms.lean`.

## Merge and cleanup
Merge with the bare `gh pr merge <N> --squash` once every §8 gate passes (ADR 0002).
Then: remove the worktree, SIGTERM your worker side-processes
(`. .claude/hooks/codex-chains.sh; for p in $(codex_chain_pids); do case "$(readlink /proc/$p/cwd)" in {{worktree_path}}*) kill "$p";; esac; done`),
report done.

## Boundaries
Do not file follow-up Issues (report them; the orchestrator files). Escalate early with a
precise question at a real design fork — never guess past it. Do not change a statement's
text, the mathlib pin, `docs/math/`, guards or CI without a ruling on the Issue.
```
