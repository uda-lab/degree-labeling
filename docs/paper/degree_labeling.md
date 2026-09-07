# Degree-ordered labellings with monotone weighted neighbour sums

T. Uda

## Abstract

Let \(G=(V,E)\) be a finite simple graph with \(n=|V|\). A zero-based labelling is a
bijection \(f:V\to\{0,\ldots,n-1\}\). We prove that \(f\) can be chosen so that
smaller degree receives the larger label and, among equal-degree vertices, the
larger-labelled vertex has the smaller-or-equal weighted neighbour sum for every
strictly increasing sequence of real weights. The powers-of-two case follows by
using the weight \(2^k\) at label \(k\). The proof chooses a minimiser of an edge
potential among the finite set of degree-respecting labellings and analyses an
exchange of two equal-degree labels.

## 1. Setting and statements

The graph is finite, simple, and undirected. Write \(d(v)\) for the degree of \(v\)
and \(N(v)\) for its neighbourhood. For real numbers
\(c_0<\cdots<c_{n-1}\), set

\[
S_v^{(c)}(f)=\sum_{u\in N(v)}c_{f(u)}.
\]

Theorem 1. There is a bijection \(f:V\to\{0,\ldots,n-1\}\) such that

\[
d(v)<d(w)\Longrightarrow f(w)<f(v)
\]

and

\[
d(v)=d(w),\ f(w)<f(v)\Longrightarrow
S_v^{(c)}(f)\leq S_w^{(c)}(f).
\]

Theorem 2. There is a bijection \(f:V\to\{0,\ldots,n-1\}\) such that the first
condition above holds and

\[
d(v)=d(w),\ f(w)<f(v)\Longrightarrow
\sum_{u\in N(v)}2^{f(u)}\leq\sum_{u\in N(w)}2^{f(u)}.
\]

Theorem 2 uses natural-number sums. Neither theorem assumes connectedness, an
upper degree bound, or positive weights in Theorem 1.

## 2. Proof of Theorem 1

Let \(\mathcal A\) be the set of degree-respecting labellings. It is nonempty:
order the vertices by decreasing degree, choose any order inside each degree class,
and assign \(0,\ldots,n-1\) in that order. It is finite because there are only
finitely many bijections between two \(n\)-element sets.

For \(g\in\mathcal A\), define

\[
\Phi(g)=\sum_{\{x,y\}\in E}c_{g(x)}c_{g(y)}.
\]

Choose \(f\in\mathcal A\) that minimises \(\Phi\). Suppose
\(d(v)=d(w)\) and \(f(w)<f(v)\). Put

\[
a=c_{f(v)},\qquad b=c_{f(w)},\qquad
A_v=\sum_{\substack{u\in N(v)\\u\ne w}}c_{f(u)},\qquad
A_w=\sum_{\substack{u\in N(w)\\u\ne v}}c_{f(u)}.
\]

Then \(a>b\). Exchange the labels of \(v\) and \(w\), producing \(f'\). Equal
degrees imply that \(f'\) remains in \(\mathcal A\).

Partition \(E\) into four disjoint classes: edges incident with neither of \(v,w\),
edges incident with \(v\) but not \(w\), edges incident with \(w\) but not \(v\),
and edges incident with both. The first class contributes no change. The last
class is either empty or consists of \(\{v,w\}\), whose contribution is \(ab\)
before and after the exchange. The other two classes give

\[
\Phi(f')-\Phi(f)
=(a-b)(A_w-A_v).
\]

Minimality gives \(\Phi(f')-\Phi(f)\geq0\), so \(A_v\leq A_w\). If \(v\) and \(w\)
are adjacent, then

\[
S_v^{(c)}(f)=A_v+b,\qquad S_w^{(c)}(f)=A_w+a.
\]

If they are not adjacent, the two sums are \(A_v\) and \(A_w\). In either case
\(S_v^{(c)}(f)\leq S_w^{(c)}(f)\), proving Theorem 1.

## 3. Proof of Theorem 2

Apply Theorem 1 to \(c_k=2^k\) for \(0\leq k<n\). These real weights are strictly
increasing. The resulting inequalities remain valid after restricting the sums to
natural numbers, which gives Theorem 2.

## 4. Boundary cases and limitations

The empty graph has its unique empty labelling. In an edgeless graph every
neighbour sum is an empty sum, so the tie condition is automatic. The theorems
assert existence, not uniqueness, canonicity, or an algorithm for finding a
labelling. Strict increase of the weight sequence is used in the exchange
argument; no claim is made here for merely non-decreasing weights.

## 5. Machine-checked formulation

The two theorems and the intermediate results for admissible labellings, the edge
potential, the exchange identity, and the minimiser are proved in Lean 4. The
public declarations are

- exists_degreeOrdered_labeling_strictMonoWeights;
- exists_degreeOrdered_labeling_powersOfTwo;
- admissibleLabeling_nonempty;
- exists_minimal_edgePotential;
- respectsDegreeOrder_swapVertices;
- edgePotential_swapVertices_sub; and
- minimizer_respectsEqualDegreeNeighborSums.

The proofs contain no sorry. Their axiom closures are contained in
\(\{\texttt{propext},\texttt{Classical.choice},\texttt{Quot.sound}\}\), as checked
by the live axiom audit.

## References

Smooth Pudding, 「炭化水素を列挙してみた（単結合のみ） [Enumerating hydrocarbons
(single bonds only)]」, 5 June 2024. The post attributes the problem to an
earlier post dated 29 May 2024.

H. L. Morgan, “The Generation of a Unique Machine Description for Chemical
Structures—A Technique Developed at Chemical Abstracts Service,” *Journal of
Chemical Documentation* 5 (1965), 107–113.
