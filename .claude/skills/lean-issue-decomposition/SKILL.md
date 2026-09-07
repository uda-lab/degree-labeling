---
name: lean-issue-decomposition
description: Turn a mathematical digest (docs/math) into an executable GitHub Issue queue for a Lean formalisation loop — statement-contract Issue first, worker-sized source-anchored block Issues, dependency graph on the charter, agent:ready audit, and the ruled-design comment a driver executes. Use in Init Phase 4 and whenever an Issue turns out larger than filed.
---

# lean-issue-decomposition

Input: the charter Issue and `docs/math/<digest>.md`. Output: Issues an orchestrator can
dispatch one at a time with a ruled design, each closable by one driver with worker jobs of
≤ 400 Lean lines. No planning document is produced; the Issues and the charter's milestone
list *are* the plan.

## 1. Statement contract first

The first Issue (M1) fixes the target's Lean statements before any proof: a `Defs.lean`
(or equivalently named module) holding the main theorem(s) and the interface they quantify
over, stated in the source's vocabulary, with proofs and data holes marked
`sorry -- ALLOW_SORRY: #<M1> statement contract`. When the repository's audit rejects
`sorryAx` on pinned names and its coverage guard pins every public theorem (as
`lean-formalization-scaffold` does), state the contract holes as `private theorem` so they are
neither pinned nor public; the proving PR removes `private` and pins. Every convention choice
is written in the docstring (sign, normalisation, quantifier order, domain, topology). Its
acceptance criteria: a judge distinct from the implementer records a source ↔ Lean audit on the
Issue; the file compiles; the coverage guard is unaffected (private holes are neither pinned nor
public; the proving PR removes `private` and pins). From then on **the statement text is
frozen**: a PR that changes it is statement-changing and needs the same audit again.

## 2. Block Issues

Walk the source's lemma route backwards from the target. For each node:

- **Source anchor**: paper, theorem/lemma/equation number, page; the literal claim with the
  source's hypotheses (the Issue template's fields are mandatory).
- **Lean target**: a signature or a precise semantic target with domains and quantifier order;
  name the declarations it will export and which contract holes it discharges.
- **Size**: one driver, worker jobs of ≤ 400 Lean lines, roughly ≤ 1500 lines total. Larger
  → split by lemma group or by "interface Issue + instance Issue". A block that needs a
  mathlib API the source does not mention gets its own recon Issue (judge or worker, read-only:
  API sweep, no Lean written).
- **Dependencies**: Issues, declarations on `main` by name, mathlib. Dependencies merged or
  explicitly out of scope before `agent:ready`.
- **Ambiguities**: every place the source is implicit; the Issue decides them or names the
  judge that will.
- **Acceptance**: declarations by name, sorry-free, pinned in `scripts/print_axioms.lean`,
  `scripts/check.sh` green, review evidence; for source-sensitive blocks the correspondence
  section of the PR filled.

Order by danger, not ease (`lean-formalization-discipline`): the load-bearing analytic step,
the hypothesis most likely to be unprovable as stated, and the mathlib gap go first, while
the loop still has budget to change the route. Cheap connected wins are filler, not progress.

## 3. Dependency graph on the charter

Append the milestone list and an ASCII dependency graph to the charter Issue; tick milestones
as PRs merge (the orchestrator edits, drivers do not). No separate roadmap file.

## 4. `agent:ready` audit

Only the owner or the trusted maintainer applies `agent:ready`, after recording on the Issue:

1. scope and acceptance criteria are explicit and machine-checkable where possible;
2. for source-sensitive work, the source audit by an agent distinct from the eventual
   implementer (judge, reasoning tier, read-only: literal claim vs source, hypotheses
   preserved, no proxy assumptions);
3. dependencies merged or explicitly out of scope; no hard-stop label.

## 5. The ruled-design comment

Before dispatch the orchestrator posts one comment on the Issue that the driver executes:

```
### Ruling: route and inputs
Route: <the proof route in 3–6 steps, each naming the source lemma it follows>
Discharge: <declarations, byte-identical to the contract>
Inputs on main: <declarations by fully qualified name, file>
Do not: <the shortcuts the source does not license — proxy hypotheses, a stronger axiom, a
symmetry the theory does not have>
Traps: <mathlib API gaps, convention mismatches, earlier review findings>
Worker policy: <tier per block, resolved to the contract's model/effort>
```

Everything a driver would otherwise have to guess goes here; a routine-tier driver with a
ruled design outperforms an unruled reasoning-tier driver. When a driver escalates a fork, the
answer is a second ruling comment, not a message.

## 6. Re-decomposition

An Issue larger than filed is split by the orchestrator into child Issues linked from the
parent; the driver keeps the parent's branch for the part it can finish and pushes a
gate-green commit before stopping. Never widen an Issue in flight.
