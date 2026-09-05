Orchestrator tick for this repository. Load `.claude/skills/<project>-orchestration/SKILL.md`,
`loop-orchestration-scaffold`, `github-loop-engineering`. Do exactly one Observe → Select →
Act cycle from current GitHub state; do not implement anything yourself.

1. Observe: open PRs (gates, review evidence, age of the newest head), Issues with
   `agent:ready` and no PR, hard-stop labels, new comments addressed to you, the driver
   registry in `.claude/scratch/drivers.md` if one exists.
2. For each in-flight PR: merge-ready and idle → merge per ADR 0002 (bare
   `gh pr merge <N> --squash`) only if its driver is gone; otherwise re-engage the driver once
   with the exact condition. Stalled (no push, no comment, no build > 60 min) → read the driver
   transcript tail, re-engage once or stop-and-redispatch on the same branch.
3. If no Issue is in flight and an authorised, unblocked Issue exists: rule the design on the
   Issue, dispatch one driver from `references/dispatch-prompt.md` with a named model.
4. If nothing is executable: report why in the no-fake-blocker structure and stop. Do not
   manufacture work; do not poll.
5. Update the container contract if a measured fact changed (through a PR, not scratch).

End with: Done / Gate state / Next automatic action / Blocker (if any, with category).
