# Degree-respecting labellings

Let \(G=(V,E)\) be a finite simple undirected graph. Write \(n=|V|\), let
\(d(v)\) denote the degree of \(v\), and let

\[
N(v)=\{u\in V:\{u,v\}\in E\}
\]

denote the neighbourhood of \(v\). A zero-based labelling is a bijection

\[
f:V\longrightarrow\{0,1,\ldots,n-1\}.
\]

For a real sequence \(c_0,c_1,\ldots,c_{n-1}\), define the weighted neighbour sum

\[
S_v^{(c)}(f)=\sum_{u\in N(v)}c_{f(u)}.
\]

A labelling respects the degree order when

\[
d(v)<d(w)\quad\Longrightarrow\quad f(w)<f(v).
\]

It respects the equal-degree neighbour-sum order for \(c\) when

\[
d(v)=d(w)\ \text{and}\ f(w)<f(v)\quad\Longrightarrow\quad
S_v^{(c)}(f)\leq S_w^{(c)}(f).
\]

## The two existence theorems

Theorem 1. If

\[
c_0<c_1<\cdots<c_{n-1},
\]

then there is a zero-based labelling that respects both the degree order and the
equal-degree neighbour-sum order for \(c\). No positivity assumption is imposed on
the weights.

Theorem 2. There is a zero-based labelling \(f\) such that

\[
d(v)<d(w)\quad\Longrightarrow\quad f(w)<f(v),
\]

and

\[
d(v)=d(w)\ \text{and}\ f(w)<f(v)\quad\Longrightarrow\quad
\sum_{u\in N(v)}2^{f(u)}\leq\sum_{u\in N(w)}2^{f(u)}.
\]

The sums in Theorem 2 are sums of natural numbers.

## Proof of Theorem 1

Consider the set \(\mathcal A\) of all zero-based labellings that respect the degree
order. This set is nonempty: order the vertices by decreasing degree, choose any
order within each degree class, and assign the labels \(0,1,\ldots,n-1\) in that
order. The set \(\mathcal A\) is finite.

For \(g\in\mathcal A\), define the edge potential

\[
\Phi(g)=\sum_{\{x,y\}\in E}c_{g(x)}c_{g(y)}.
\]

Since \(\mathcal A\) is finite and nonempty, choose \(f\in\mathcal A\) for which
\(\Phi(f)\) is minimal.

Take vertices \(v,w\) with \(d(v)=d(w)\) and \(f(w)<f(v)\). Put

\[
a=c_{f(v)},\qquad b=c_{f(w)},\qquad
A_v=\sum_{\substack{u\in N(v)\\u\ne w}}c_{f(u)},\qquad
A_w=\sum_{\substack{u\in N(w)\\u\ne v}}c_{f(u)}.
\]

Strict monotonicity gives \(b<a\). Let \(f'\) be obtained from \(f\) by exchanging
the labels of \(v\) and \(w\). Because \(v\) and \(w\) have equal degree, \(f'\) is
still in \(\mathcal A\).

To calculate the change in the potential, partition the edge set into four disjoint
classes. Let \(E_v\) consist of edges incident with \(v\) but not \(w\), let \(E_w\)
consist of edges incident with \(w\) but not \(v\), let \(E_{vw}\) consist of edges
incident with both \(v\) and \(w\), and let \(E_0\) be the remaining edges. The
classes cover \(E\). Edges in \(E_0\) are unchanged by the exchange. If
\(\{v,w\}\in E\), then \(E_{vw}=\{\{v,w\}\}\) and its contribution is \(ab\) both
before and after the exchange. If \(\{v,w\}\notin E\), then \(E_{vw}\) is empty.

The contributions from \(E_v\) and \(E_w\) therefore give

\[
\Phi(f')-\Phi(f)=bA_v+aA_w-aA_v-bA_w
=(a-b)(A_w-A_v).
\]

Minimality of \(f\) implies \(\Phi(f')-\Phi(f)\geq0\). Since \(a-b>0\), it follows
that

\[
A_v\leq A_w.
\]

It remains to restore the possible edge between \(v\) and \(w\). If \(v\) and \(w\)
are adjacent, then

\[
S_v^{(c)}(f)=A_v+b,\qquad S_w^{(c)}(f)=A_w+a,
\]

so \(S_v^{(c)}(f)\leq S_w^{(c)}(f)\). If they are not adjacent, then
\(S_v^{(c)}(f)=A_v\) and \(S_w^{(c)}(f)=A_w\), and the same inequality follows.
Thus the chosen labelling proves Theorem 1.

## Proof of Theorem 2

Apply Theorem 1 to the strictly increasing real weights

\[
c_i=2^i\qquad(0\leq i<n).
\]

The resulting real inequalities are exactly the natural-number inequalities in
Theorem 2 after the usual inclusion of the natural numbers into the real numbers.

## Scope and convention

The results include the empty graph and graphs with vertices but no edges. They are
existence results; they assert neither uniqueness nor a method for constructing a
particular labelling. Connectedness and an upper bound on the degrees are not
assumed. Strict increase of the weights is used; mere non-decrease is not covered.

The original formulation assigns the labels \(1,\ldots,n\) and gives label \(k\) the
weight \(2^k\). Adding one to every zero-based label multiplies every neighbour sum
by \(2\), while translating in the reverse direction divides every sum by \(2\).
The factor is common to all vertices and positive, so both ordering conditions are
unchanged. The two formulations are therefore equivalent.
