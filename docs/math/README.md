# docs/math — mathematical source of truth

This directory holds the **working digest** of the source `[P]` and nothing else: exact
statements to be formalised, the conventions the Lean development commits to, and the
bibliography. It is amended only through PRs that cite the source; the primary source wins on
any conflict with a digest.

- `references.md` — the primary sources with their citation keys used in Issues and
  docstrings: `[P]` (the owner's note, the primary source for T1 and T2), `[SP24]` (the
  problem's origin), `[M65]` (context only, not a source of statements). The papers/notes
  themselves are **not** tracked; local copies live under `sources/` (gitignored).
- `degree_labeling.md` — the digest: T1 and T2 verbatim in `[P]`'s vocabulary, the
  definitions, the S1–S7 proof route, the conventions the Lean encoding commits to.

A digest is not a status document: it records what the mathematics *is*, never which Issue
landed what — that lives in Issues, PRs and Git history.
