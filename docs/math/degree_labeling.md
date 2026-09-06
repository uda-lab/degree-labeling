# Degree labeling: mathematical digest

This digest is the working mathematical source of truth for the Init phase. The primary
source is [P](references.md), whose local copy is `sources/problem.md`. The statements
preserve the source vocabulary; later encoding decisions explain the eventual Lean
representation of the same labels and comparisons. This file introduces no Lean declarations.

## Ambient setting and definitions

Throughout, \(G=(V,E)\) is a **finite simple undirected graph**, \(n=|V|\), and \(d(v)\) is
the degree of \(v\). There are no loops or multiple edges. For \(u,v\in V\), write
\(u\sim v\) for adjacency and take every neighbour sum over \(\{u\in V\mid u\sim v\}\).

A source *labelling* is a bijection \(f:V\longrightarrow\{1,\ldots,n\}\). The source's
labels are ordered increasingly, so \(f(v)>f(w)\) is an order comparison of those labels.

## Target statements in source vocabulary

### T1 (principal result — strictly increasing weights)

Let \(c_1<c_2<\cdots<c_n\) be real numbers (with **no positivity assumption**). For a
labelling \(f\), define \(S^{(c)}_v=\sum_{u\sim v}c_{f(u)}\). Then there exists a labelling
such that:

1. \(d(v)<d(w)\implies f(v)>f(w)\), and
2. \(d(v)=d(w) \text{ and } f(v)>f(w)\implies S^{(c)}_v\le S^{(c)}_w\).

### T2 (original problem, corollary)

For every finite simple undirected graph there exists a labelling \(f\) such that:

1. \(d(v)<d(w)\implies f(v)>f(w)\), and
2. with \(S_v=\sum_{u\sim v}2^{f(u)}\), \(d(v)=d(w) \text{ and } f(v)>f(w)\implies
   S_v\le S_w\).

T2 follows from T1 with \(c_k=2^k\). In particular, connectedness and the bound
\(d(v)\le4\) are unnecessary.

## Lean representation conventions fixed in Init

- A source labelling is represented by a bijection to `Fin n`, whose values are 0-based.
  For a vertex \(v\), its source label is **defined to mean**
  \(\ell_f(v)=f(v).val+1\); hence source comparisons use the corresponding `Fin`
  comparisons, e.g. \(f(v)>f(w)\) means `f(v).val > f(w).val`.
- The T1 sequence remains \(c_1,\ldots,c_n\): on `Fin n`, the entry at `f(u)` denotes
  \(c_{f(u).val+1}\), with strict increase in that induced source order. The argument uses
  strict increase, not positivity; its ordered target is an ordered commutative ring
  (the source theorem takes real weights).
- T2 retains the source's 1-based exponent. Under `Fin n` its sum is
  **\(\displaystyle S_v=\sum_{u\sim v}2^{\,f(u).val+1}\)**, not the unaccounted
  0-based weight \(2^{f(u).val}\). Since
  \(2^{f(u).val+1}=2\cdot2^{f(u).val}\), a common positive factor would preserve
  comparisons, but the stated T2 convention remains the source expression.
- The empty graph \(n=0\) is included: its empty vertex type has its empty bijection and
  empty neighbour sums. Edgeless graphs with vertices are also included, and no positivity
  assumption is added for T1 weights.

## Proof route from the source

The following S1–S7 route is the source's proof sketch and the intended dependency route.

### S1 — \(\mathcal F\neq\varnothing\)

Order the vertices by non-increasing degree, breaking ties arbitrarily, and assign the
labels \(1,\ldots,n\) in that order. Let
\[
\mathcal F=\{g:V\to\{1,\ldots,n\}\mid g\text{ is bijective and }
d(v)<d(w)\Rightarrow g(v)>g(w)\}.
\]
This construction gives an element of \(\mathcal F\).

### S2 — potential

For \(g\in\mathcal F\), define
\[
  \Phi(g)=\sum_{\{x,y\}\in E}c_{g(x)}c_{g(y)}.
\]
Since \(\mathcal F\) is finite and nonempty, choose \(f\in\mathcal F\) minimising
\(\Phi\). In the eventual formalisation, the admissible bijections must be represented by
a finite type or `Finset`, not merely as a proposition, so this minimisation has an
explicit finite domain.

### S3 — setup of a swap

Take \(v,w\) with \(d(v)=d(w)\) and \(f(v)>f(w)\). Put
\(a=c_{f(v)}\) and \(b=c_{f(w)}\); strict monotonicity gives \(a>b\). Define
\[
  A_v=\sum_{\substack{u\sim v\\u\ne w}}c_{f(u)},\qquad
  A_w=\sum_{\substack{u\sim w\\u\ne v}}c_{f(u)}.
\]
Let \(f'\) be \(f\) with the labels of \(v\) and \(w\) exchanged. Since
\(d(v)=d(w)\), the exchange preserves the degree-order condition, so \(f'\in\mathcal F\).

### S4 — swap identity

Only edges incident to \(v\) or \(w\) change their contribution to \(\Phi\). If
\(v\sim w\), the edge \(\{v,w\}\) contributes \(ab\) before and after. Hence
\[
  \Phi(f')-\Phi(f)=bA_v+aA_w-aA_v-bA_w
  =(a-b)(A_w-A_v).
\]
The edge bookkeeping uses simplicity and the absence of loops; the possible edge
\(\{v,w\}\) is handled explicitly rather than counted twice.

### S5 — minimality

\(\Phi(f')-\Phi(f)\ge0\) by minimality, and \(a-b>0\). Therefore
\(A_v\le A_w\).

### S6 — restore the possible edge

Let \(\varepsilon=1\) if \(v\sim w\) and \(0\) otherwise. Then
\[
  S^{(c)}_v=A_v+\varepsilon b,\qquad
  S^{(c)}_w=A_w+\varepsilon a,
\]
so
\[
  S^{(c)}_w-S^{(c)}_v=(A_w-A_v)+\varepsilon(a-b)\ge0.
\]
This is the desired tie-order inequality.

### S7 — T2

Specialise T1 to \(c_k=2^k\), retaining the source's 1-based exponent. Under the
decided Lean convention this is the explicit exponent \(f(u).val+1\) described above.

## Scope and non-goals

The principal result is T1 and T2 is its corollary. The formalisation does not target
enumeration of hydrocarbon graphs, the Morgan algorithm, uniqueness or canonicity of a
labelling, algorithmic complexity, or weights that are merely non-decreasing.
