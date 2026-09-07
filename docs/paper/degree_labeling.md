# Degree-ordered labellings with monotone weighted neighbour sums

T. Uda

## Abstract

Let \(G = (V, E)\) be a finite simple graph on \(n\) vertices. We show that the vertices of
\(G\) can always be labelled with \(1, \ldots, n\) so that (i) the labelling is monotone in the
degree sequence — higher-degree vertices receive smaller labels — and (ii) among vertices of
equal degree, weighted sums of neighbours' labels are monotone in the vertex's own label, for
*every* choice of strictly increasing real weights attached to the labels. This is Theorem 1
below. Specialising the weight of label \(k\) to \(2^{k}\) recovers a labelling problem that
first arose in the combinatorial enumeration of hydrocarbon graphs, stated originally for
connected graphs of maximum degree \(4\); Theorem 2 shows that neither hypothesis is needed.
The proof is a direct finite-minimisation and exchange argument: among the (finitely many)
degree-monotone labellings, one that minimises a quadratic potential already has the required
property, because any pair of equal-degree vertices whose labels are "out of order" could be
swapped without increasing the potential, and working out the effect of that swap forces the
order asserted by the theorem. The result and its proof have been formalised and machine
checked in the Lean 4 proof assistant; see the closing remark.

## 1. Introduction

Consider labelling the atoms of a hydrocarbon molecule — modelled as vertices of a graph, with
bonds as edges — with the consecutive integers \(1, \ldots, n\), each used exactly once, so that
the labels reflect the molecule's connectivity: atoms with more bonds should be distinguishable
from atoms with fewer, and among atoms with the same number of bonds, some canonical rule should
break the remaining ties. A natural rule, proposed in the context of enumerating hydrocarbon
graphs with only single bonds, is to give atoms with more bonds the smaller labels, and then to
break ties among equal-bond atoms using a *weighted sum over neighbours*: weight each label
exponentially by a power of two, and require that among atoms with the same number of bonds, the
one with the numerically larger label have a smaller-or-equal sum of its neighbours' weights.
Concretely, if atom \(v\) is bonded to atoms \(u_1, \ldots, u_d\), and \(f\) is the labelling
function, its neighbour sum is \(S_v = \sum_i 2^{f(u_i)}\), and the requirement is that larger
labels within a fixed bond count correspond to smaller-or-equal neighbour sums.

The original formulation of this labelling problem assumed the graph was connected and every
vertex had degree at most \(4\), reflecting the valence of carbon. Neither hypothesis is needed:
the labelling exists for every finite simple graph, connected or not, with vertices of arbitrary
degree, including isolated vertices and the empty graph. Moreover the powers-of-two weighting is
not special — the same labelling exists for the neighbour sum built from *any* strictly
increasing sequence of real numbers assigned to the labels, with no assumption that the numbers
are positive. We record this general statement as Theorem 1 and the original powers-of-two
problem as Theorem 2, its immediate corollary.

The rest of the paper is organised as follows. Section 2 fixes terminology and notation.
Section 3 states Theorem 1 and Theorem 2 precisely. Section 4 proves Theorem 1 by a
finite-minimisation and vertex-swap argument. Section 5 derives Theorem 2. Section 6 records
scope remarks — the absence of a positivity hypothesis, the inclusion of empty and edgeless
graphs, and what the theorems do not claim. Section 7 is a short remark on the independent
machine verification of these results.

## 2. Preliminaries

Throughout, \(G = (V, E)\) is a **finite simple graph**: \(V\) is a finite set of vertices,
\(E\) is a set of unordered pairs of distinct vertices (edges), with no loops and no repeated
edges. We write \(n = |V|\). For \(u, v \in V\) we write \(u \sim v\) to mean \(\{u, v\} \in E\)
("\(u\) and \(v\) are adjacent"). The **degree** \(d(v)\) of a vertex \(v\) is the number of
vertices adjacent to it, \(d(v) = |\{u \in V : u \sim v\}|\). A **neighbour sum** over \(v\) is a
sum taken over exactly those vertices adjacent to \(v\); the graph being simple, this sum has no
repeated terms and no self-term.

A **labelling** of \(G\) is a bijection \(f : V \to \{1, \ldots, n\}\), i.e. an assignment of the
integers \(1, \ldots, n\) to the vertices of \(G\), each integer used exactly once. We call
\(f(v)\) the *label* of \(v\); labels are compared as integers, so "\(f(v) > f(w)\)" is an
ordinary numerical comparison. Two vertices are **tied** (for the purposes of this paper) when
they have equal degree.

We say a labelling \(f\) is **degree-respecting** if a vertex of strictly smaller degree always
receives a strictly larger label than a vertex of strictly larger degree:
$$
d(v) < d(w) \implies f(v) > f(w) \qquad \text{for all } v, w \in V. \tag{$\ast$}
$$
Equivalently, sorting the vertices by label from \(1\) to \(n\) sorts them by non-increasing
degree; ties (vertices of equal degree) may occur consecutively in either relative order. A
degree-respecting labelling always exists: order the vertices by non-increasing degree, breaking
ties in any fixed way, and assign labels \(1, \ldots, n\) in that order.

Given real numbers \(c_1, \ldots, c_n\) (thought of as weights attached to the labels
\(1, \ldots, n\)) and a labelling \(f\), the **weighted neighbour sum** of a vertex \(v\) is
$$
S^{(c)}_v = \sum_{u \sim v} c_{f(u)},
$$
the sum, over the neighbours of \(v\), of the weight attached to each neighbour's label. (When
\(v\) has no neighbours the sum is \(0\) by convention, as an empty sum.) The weighted neighbour
sum depends on the vertex \(v\), the labelling \(f\), and the weight sequence \(c\); we suppress
this dependence in the notation once \(f\) and \(c\) are fixed. We call a sequence
\(c_1 < c_2 < \cdots < c_n\) — with *no* assumption that the \(c_i\) are positive — a **strictly
increasing weight sequence**.

## 3. Statement of results

**Theorem 1 (degree-ordered labelling for monotone weights).**
*Let \(G = (V, E)\) be a finite simple graph on \(n\) vertices, and let
\(c_1 < c_2 < \cdots < c_n\) be a strictly increasing sequence of real numbers. Then there
exists a labelling \(f : V \to \{1, \ldots, n\}\) such that*

1. *(degree order) \(d(v) < d(w) \implies f(v) > f(w)\) for all \(v, w \in V\); and*
2. *(tie order) for all \(v, w \in V\) with \(d(v) = d(w)\) and \(f(v) > f(w)\), the weighted
   neighbour sums satisfy \(S^{(c)}_v \le S^{(c)}_w\).*

That is, \(f\) is degree-respecting, and among any two vertices tied on degree, the one with the
numerically larger label has the smaller-or-equal weighted neighbour sum.

**Theorem 2 (the powers-of-two case; the original problem).**
*Let \(G = (V, E)\) be a finite simple graph on \(n\) vertices. Then there exists a labelling
\(f : V \to \{1, \ldots, n\}\) such that*

1. *\(d(v) < d(w) \implies f(v) > f(w)\) for all \(v, w \in V\); and*
2. *writing \(S_v = \sum_{u \sim v} 2^{f(u)}\), for all \(v, w \in V\) with \(d(v) = d(w)\) and
   \(f(v) > f(w)\), the sums satisfy \(S_v \le S_w\).*

Theorem 2 is the special case of Theorem 1 in which the weight sequence is \(c_k = 2^k\) for
\(k = 1, \ldots, n\), which is strictly increasing; the derivation is given in Section 5.
Neither theorem assumes \(G\) is connected, and neither bounds the degree of any vertex — in
particular the hypothesis "every vertex has degree at most \(4\)", present in the original
hydrocarbon-graph formulation of Theorem 2, is not needed.

## 4. Proof of Theorem 1

Fix the finite simple graph \(G = (V, E)\), \(n = |V|\), and the strictly increasing weight
sequence \(c_1 < \cdots < c_n\). Call a labelling \(f\) **admissible** if it is
degree-respecting, i.e. satisfies condition \((\ast)\) of Section 2. We must produce an
admissible labelling that also satisfies condition 2 of Theorem 1.

### 4.1 The set of admissible labellings is finite and nonempty

There are only finitely many labellings of \(G\) at all — a labelling is a bijection from an
\(n\)-element set to \(\{1, \ldots, n\}\), and there are \(n!\) of these — so in particular there
are only finitely many admissible ones. The set of admissible labellings is also nonempty: order
the vertices of \(V\) by non-increasing degree, breaking ties among equal-degree vertices in any
fixed way (e.g. by an arbitrary auxiliary enumeration of \(V\)), and assign the labels
\(1, \ldots, n\) to the vertices in that order, smallest label to the first (highest-degree)
vertex in the order and largest label to the last (lowest-degree) vertex.
By construction, if \(d(v) < d(w)\) then \(v\) occurs strictly after \(w\) in the order, so
\(f(v) > f(w)\); this is exactly condition \((\ast)\). (When \(n = 0\), the unique labelling of
the empty vertex set is vacuously admissible.)

### 4.2 A potential function and its minimiser

For a labelling \(g\), define its **potential**
$$
\Phi(g) = \sum_{\{x, y\} \in E} c_{g(x)} \, c_{g(y)},
$$
the sum, over all edges of \(G\), of the product of the weights of the two endpoints' labels.
(The summand does not depend on which endpoint of the edge is called \(x\) and which \(y\),
since the product is symmetric, so \(\Phi\) is well defined on unordered edges.) Since the set of
admissible labellings is finite and nonempty (Section 4.1), it contains a labelling \(f\)
minimising \(\Phi\) among admissible labellings:
$$
\Phi(f) \le \Phi(g) \quad \text{for every admissible labelling } g.
$$
We claim that this minimiser \(f\) already satisfies condition 2 of Theorem 1. The remainder of
the proof establishes this claim by considering, for a fixed minimiser \(f\), an arbitrary pair
of tied vertices whose labels are out of the order that condition 2 requires, and showing that
exchanging their labels cannot decrease \(\Phi\) — which, worked out explicitly, forces the
required order.

### 4.3 The effect of exchanging two tied vertices' labels

Fix two vertices \(v, w \in V\) with \(d(v) = d(w)\) and \(f(v) > f(w)\); this is exactly the
hypothesis of condition 2 for the pair \((v, w)\), and our goal is to derive its conclusion
\(S^{(c)}_v \le S^{(c)}_w\) for this pair. Since \(f(v) \ne f(w)\), certainly \(v \ne w\). Let
\(f'\) be the labelling obtained from \(f\) by exchanging the labels of \(v\) and \(w\) and
leaving every other vertex's label unchanged: \(f'(v) = f(w)\), \(f'(w) = f(v)\), and
\(f'(x) = f(x)\) for \(x \ne v, w\).

**The exchanged labelling is admissible.** We must check condition \((\ast)\) for \(f'\) on
every pair of vertices. For the pair \((v, w)\) itself, \((\ast)\) is vacuous: its antecedent
\(d(v) < d(w)\) or \(d(w) < d(v)\) is false, since \(d(v) = d(w)\). For a pair not meeting
\(\{v, w\}\) at all, neither vertex's label or degree changed, so \((\ast)\) holds for \(f'\)
because it held for \(f\). It remains to check a pair \((x, v)\) or \((x, w)\) with
\(x \notin \{v, w\}\); by symmetry (\(f'\) restricted to \(v\) and \(w\) is \(f\) restricted to
\(w\) and \(v\), respectively) it suffices to check \((x, v)\). If \(d(x) < d(v)\), then also
\(d(x) < d(w)\) (as \(d(v) = d(w)\)), so \((\ast)\) for \(f\) on the pair \((x, w)\) gives
\(f(x) > f(w)\), i.e. \(f(x) > f'(v)\), which is \((\ast)\) for \(f'\) on \((x, v)\). If instead
\(d(v) < d(x)\), then \(d(w) < d(x)\), so \((\ast)\) for \(f\) on \((w, x)\) gives
\(f(w) > f(x)\), i.e. \(f'(v) > f(x)\), again \((\ast)\) for \(f'\) on \((x, v)\). So \((\ast)\)
holds for \(f'\) on every pair, and \(f'\) is admissible. By minimality of \(f\),
$$
\Phi(f') \ge \Phi(f). \tag{4.1}
$$

**Working out \(\Phi(f') - \Phi(f)\).** An edge of \(G\) not incident to \(v\) or \(w\) has both
endpoints' labels unchanged by the swap, so it contributes equally to \(\Phi(f')\) and
\(\Phi(f)\); such edges cancel out of the difference \(\Phi(f') - \Phi(f)\). It remains to
account for edges incident to \(v\) or to \(w\) (or, possibly, both, if \(v \sim w\)). Write
$$
a = c_{f(v)}, \qquad b = c_{f(w)},
$$
the weights of \(v\)'s and \(w\)'s labels under \(f\); since \(c\) is strictly increasing and
\(f(v) > f(w)\), we have \(a > b\). Define the neighbour sums of \(v\) and \(w\) under \(f\)
*excluding* one another:
$$
A_v = \sum_{u \sim v,\ u \ne w} c_{f(u)}, \qquad A_w = \sum_{u \sim w,\ u \ne v} c_{f(u)}.
$$
Consider first an edge \(\{v, u\}\) with \(u \ne w\) (so \(u\) is a neighbour of \(v\) other than
\(w\), and, \(G\) being simple, \(u \ne v\)). Under \(f\) this edge contributes \(a \cdot c_{f(u)}\)
to \(\Phi\); under \(f'\), \(v\)'s label has become \(b\) while \(u\)'s label is unchanged (as
\(u \ne w\)), so the edge now contributes \(b \cdot c_{f(u)}\). Summing over all such edges
contributes \((b - a) A_v\) to \(\Phi(f') - \Phi(f)\). Symmetrically, summing over edges
\(\{w, u\}\) with \(u \ne v\) contributes \((a - b) A_w\). If \(v \sim w\), the single edge
\(\{v, w\}\) contributes \(a b\) to \(\Phi(f)\) and — since the swap only exchanges the two
weights being multiplied — again \(b a = a b\) to \(\Phi(f')\), so this edge (when present)
contributes \(0\) to the difference. Adding the two contributions above,
$$
\Phi(f') - \Phi(f) = (b - a) A_v + (a - b) A_w = (a - b)(A_w - A_v). \tag{4.2}
$$
No edge of \(G\) is left unaccounted for: every edge is either disjoint from \(\{v, w\}\)
(contributes \(0\), already discussed), incident to exactly one of \(v, w\) (accounted for in
\(A_v\) or \(A_w\)), or equal to \(\{v, w\}\) itself (contributes \(0\) to the difference, just
shown) — and these cases are mutually exclusive because \(G\) is simple, so no edge is counted
twice.

### 4.4 Concluding condition 2

Combining (4.1) and (4.2), and using \(a - b > 0\), we may divide the inequality
\((a - b)(A_w - A_v) \ge 0\) by the positive number \(a - b\) to get
$$
A_v \le A_w. \tag{4.3}
$$
It remains to pass from the sums \(A_v, A_w\) (which exclude \(w\), respectively \(v\), from the
neighbour sum) to the full weighted neighbour sums \(S^{(c)}_v, S^{(c)}_w\) of condition 2. Let
\(\varepsilon = 1\) if \(v \sim w\) and \(\varepsilon = 0\) otherwise. By definition of \(A_v\)
as the neighbour sum of \(v\) excluding the single possible term contributed by \(w\),
$$
S^{(c)}_v = A_v + \varepsilon \, b, \qquad S^{(c)}_w = A_w + \varepsilon \, a,
$$
(the term "\(\varepsilon b\)" is the contribution of \(w\) to \(v\)'s neighbour sum, present
exactly when \(v \sim w\), and equal to \(c_{f(w)} = b\); symmetrically for \(w\)). Subtracting
and using (4.3),
$$
S^{(c)}_w - S^{(c)}_v = (A_w - A_v) + \varepsilon (a - b) \ge 0,
$$
since both summands are nonnegative — the first by (4.3), the second because \(\varepsilon \ge 0\)
and \(a > b\). Hence \(S^{(c)}_v \le S^{(c)}_w\), which is exactly the conclusion of condition 2
for the pair \((v, w)\).

Since \(v, w\) were an arbitrary tied pair with \(f(v) > f(w)\), condition 2 holds for the
minimiser \(f\) for every such pair, and \(f\) is admissible by construction, so \(f\) satisfies
both conditions of Theorem 1. \(\blacksquare\)

## 5. Proof of Theorem 2

Theorem 2 is the case \(c_k = 2^k\) for \(k = 1, \ldots, n\) of Theorem 1. This sequence is
strictly increasing, since \(k \mapsto 2^k\) is strictly increasing on the integers. Applying
Theorem 1 with this weight sequence produces a labelling \(f\) satisfying condition 1 of
Theorem 1 — which is condition 1 of Theorem 2, verbatim — and condition 2 of Theorem 1 with
\(c_{f(u)} = 2^{f(u)}\), i.e.
$$
S^{(c)}_v = \sum_{u \sim v} 2^{f(u)} = S_v
$$
in the notation of Theorem 2. So condition 2 of Theorem 1 for this weight sequence is exactly
condition 2 of Theorem 2. \(\blacksquare\)

In particular, the labelling produced does not depend on \(G\) being connected or on any bound
on vertex degree: Theorem 1 imposes neither hypothesis, so neither does its corollary.

## 6. Remarks

**No positivity assumption.** The weight sequence \(c_1 < \cdots < c_n\) in Theorem 1 is an
arbitrary strictly increasing sequence of real numbers; the proof in Section 4 uses only that
\(c\) is strictly increasing (to get \(a > b\) whenever \(f(v) > f(w)\)) and ordinary
arithmetic of an ordered field. No step requires any \(c_k\) to be positive. Positivity is not
needed even to make sense of the powers-of-two case, Theorem 2, where each \(c_k = 2^k\) happens
to be positive but the proof does not use this.

Strict monotonicity, by contrast, is used essentially: for a merely non-decreasing weight
sequence, the step deriving \(a > b\) in Section 4.3 fails whenever \(c_{f(v)} = c_{f(w)}\), and
the swap argument no longer forces \(S^{(c)}_v \le S^{(c)}_w\) for the minimiser. This shows only
that the proof method of Section 4 does not extend to non-decreasing weights as it stands; it is
not a demonstration that the labelling fails to exist for such weights, and this paper makes no
claim either way about that case — see the Scope remark below.

**Empty and edgeless graphs.** Theorem 1 and Theorem 2 make no standing assumption that \(G\)
has any vertices or edges. When \(V = \varnothing\) (\(n = 0\)), the unique labelling of the
empty vertex set trivially satisfies both conditions, each being a universally quantified
statement over an empty domain. When \(E = \varnothing\) but \(V \ne \varnothing\) (an edgeless
graph on \(n\) vertices, all of degree \(0\)), the labelling that assigns labels arbitrarily
still works: condition 1 is vacuous, since no two vertices have distinct degrees, and condition 2
holds because every weighted neighbour sum is \(0\) (an empty sum), so \(S^{(c)}_v \le S^{(c)}_w\)
holds trivially for every pair. Neither degenerate case requires separate treatment in the proof
of Section 4: the potential-minimisation argument specialises correctly, with the potential
\(\Phi\) itself an empty sum (hence \(0\)) whenever \(E = \varnothing\).

**Non-uniqueness.** The theorems assert existence, not uniqueness. Ties among vertices of equal
degree and equal weighted neighbour sum, and ties in the choice of degree-ordering when several
minimisers of \(\Phi\) exist, mean that in general many labellings satisfy the stated
conditions; the proof produces one such labelling without claiming it is canonical.

**Scope.** The results above are the full content of what is proved. They do not address
questions that arise naturally alongside the original hydrocarbon-graph motivation, such as
enumeration of hydrocarbon graphs, canonical or unique molecular numbering, or the algorithmic
complexity of computing the labelling. Nor do they establish any strengthening beyond Theorem 1,
such as an analogue of the tie-order condition for a merely non-decreasing (rather than strictly
increasing) weight sequence: as the remark above explains, the proof method of Section 4 does
not go through unchanged in that case, so whether such a strengthening is true is left open by
this paper.

## 7. Formal verification

Theorem 1 and Theorem 2 above, together with every intermediate lemma used in Section 4 (the
existence and finiteness of the admissible labellings, the potential-minimiser argument, the
swap identity (4.2), and its consequence (4.3)), have been formalised and machine checked in the
Lean 4 proof assistant against the Mathlib library, in the repository accompanying this note. In
the Lean development the two theorems are named
`exists_degreeOrdered_labeling_strictMonoWeights` (Theorem 1) and
`exists_degreeOrdered_labeling_powersOfTwo` (Theorem 2); labels are represented zero-based
(as `Fin n`, the standard type of natural numbers below \(n\)) with the correspondence
\(f(v) = (\text{zero-based value}) + 1\) to the one-based labels used throughout this paper, and
the neighbour sums and potentials of Sections 2 and 4 are represented by the corresponding
finite sums over the graph's edge and neighbour finsets. Both theorems, and every lemma they
depend on, are proved without any use of `sorry` or other unproved placeholders, and their axiom
closure (checked live via Lean's `#print axioms`) is contained in the three axioms
`propext`, `Classical.choice`, and `Quot.sound`, i.e. the standard axioms of classical
mathematics as embedded in Lean's type theory, and nothing beyond them. This gives an
independent, mechanically checked confirmation that the argument of Sections 4 and 5 is
correct, including the degenerate empty- and edgeless-graph cases of Section 6, which are
exercised by the same general-\(V\) statements rather than handled as separate lemmas.

## References

| Key | Reference | Role |
|---|---|---|
| `[P]` | T. Uda, owner's note (6 September 2026), unpublished; states the target theorems, their hypotheses and conventions, and a proof sketch. | Primary source for Theorem 1 and Theorem 2 as stated here. |
| `[SP24]` | Smooth Pudding (プリンくん / @mat_der_D), 「炭化水素を列挙してみた（単結合のみ）」, ぷりんの雑記帳, 5 June 2024, <https://smooth-pudding.hatenablog.com/entry/2024/06/05/235137>. | Origin of the labelling problem specialised by Theorem 2; attributes the problem to an earlier post by @mat_der_D, 29 May 2024. |
| `[M65]` | H. L. Morgan, "The Generation of a Unique Machine Description for Chemical Structures — A Technique Developed at Chemical Abstracts Service", *Journal of Chemical Documentation* 5 (1965), 107–113. | Background on canonical numbering of molecular graphs; context for the hydrocarbon motivation only, not a source of the statements proved here. |
