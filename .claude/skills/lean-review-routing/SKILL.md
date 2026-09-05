---
name: lean-review-routing
description: Review order, reviewer routes per vendor, finding classification and round ceiling for PRs in a Lean formalisation loop — local adversarial review before the PR, broker or Reviewed-by evidence on the PR, substantive-versus-not classification, five-round ceiling, and what counts as github-driven-workflow §7/§8 evidence. Use by drivers before opening a PR and after every review round, and by orchestrators when routing changes.
---

# lean-review-routing

Order, always: **local adversarial review → fix → open the PR → external review rounds →
merge.** Never run a local and an external review concurrently: the external one gets spent
on defects the local pass would have caught.

## Local review (one pass per Issue, before the PR)

Frame it as **numbered, falsifiable risks**, never "review this" (a generic prompt returns
"no major issues" on diffs with real defects). Always include:

1. no statement was weakened, specialised or trivialised; no hypothesis dropped; no conclusion
   narrowed (compare against the contract text byte for byte);
2. no proxy hypothesis replaced a source hypothesis (bounded for compact, separable for
   Polish, …);
3. every claimed public theorem is appended to `scripts/print_axioms.lean`;
4. no `sorry`/`axiom` outside an Issue-authorised `ALLOW_` marker;
5. no transient artefact, bookkeeping or chronology added to the tree;
6. the Issue's own traps.

Put `git diff main...HEAD` inside the prompt file (statements only, and say so, if the diff
exceeds the argument limit) and state what the gate already verified so the pass is not spent
re-running it. Read the result in the same turn.

Routes: codex plugin `adversarial-review --base main --scope branch "<risks>"` (Claude
configuration A); `codex review` (Codex only); a read-only subagent of a different model than
the implementer (reasoning tier preferred) otherwise. Record which route ran in the PR body.

## PR review (evidence for `github-driven-workflow` §8)

- **Broker route** (when `REVIEW_ACQUIRE_SCRIPT` is set): `python3 "$REVIEW_ACQUIRE_SCRIPT"
  <owner>/<repo> <PR> <kind>` verbatim — never copy, relocate, unset or self-point it. Kind
  order from the container contract (`codex` is the default; `copilot` while its allowance
  lasts). A cooldown between requests on one PR is not an error. A
  `chatgpt-codex-connector[bot]` reply telling you to create a Codex account is a canned
  response to an unauthorised mention, not a failure: keep waiting for the real review.
- **Bundled route**: `github-driven-workflow`'s `scripts/acquire-review.py` when no broker.
- **Reviewed-by route** (single subscription, or no bot reviewer): a read-only reviewer distinct
  from the implementer (different model or session) posts a PR comment beginning
  `Reviewed-by: <reviewer-id>` that quotes its findings and the head SHA it covered. Clause 2
  of §8 matches it. Independence is by recorded identity.

Wait for the review; minutes are normal. Poll without filtering by review state or author
login — codex delivers formal reviews as `COMMENTED`, and top-level comments count when the
driver records them as a `Reviewed-by:` artifact. Change route only on affirmative evidence
that this one will not deliver (explicit error, quota-exhausted body), never on elapsed time.

## Classification after every round

A finding is **substantive** if acting on it would change a Lean statement, the validity of a
proof step, the axiom footprint, the behaviour of a guard or CI, or the correspondence between
the Lean development and the source. Wording, naming, comment style, preference and
restatement of something already correct are not, however confidently argued.

- Substantive → fix, push, request the next round on the new head. Re-review must cover the
  final head; evidence on a stale head does not merge.
- Only non-substantive, or none → stop reviewing and merge. Do not answer, negotiate or run a
  confirmation round; the orchestrator files a hygiene Issue for anything worth keeping.

**Five rounds is the ceiling.** At the ceiling fix only unsound-proof, wrong-statement or
broken-guard findings, collect the rest into one follow-up Issue, merge without a confirmation
round, and say so in the PR body. **Same defect shape three rounds running → change the
structure**, not the instance.

## Statement-changing PRs

Any PR that adds or changes a public statement carries a source ↔ Lean correspondence section
and needs a reviewer that checks literal Lean vs source, hidden assumptions, boundary cases
and quantifier/domain mistakes. A judge (reasoning tier, read-only,
`lean-formalization-discipline`, `math-semantic-preservation`) is the right reviewer for this
even when a bot review also ran.

## Source beats digest

A reviewer's "the paper says X" is checked against the paper (fetch the arXiv/DOI text)
before ruling. Digests have been wrong in exactly this shape before.
