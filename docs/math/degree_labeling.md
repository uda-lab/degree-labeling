# Degree-respecting labellings

Let \(G=(V,E)\) be a finite simple undirected graph. Write \(n=|V|\), let
\(d(v)\) denote the degree of \(v\), and let

\[
N(v)=\{u\in V:\{u,v\}\in E\}
\]

denote the neighbourhood of \(v\). A labelling is a bijection

\[
f:V\longrightarrow I_n,
\qquad I_n=\{0,1,\ldots,n-1\}.
\]

For a strictly increasing real function \(c:I_n\to\mathbb R\), write the weighted neighbour sum

\[
\sum_{u\in N(v)}c(f(u)).
\]

A labelling respects the degree order when

\[
d(v)<d(w)\quad\Longrightarrow\quad f(w)<f(v).
\]

It respects the equal-degree neighbour-sum order for \(c\) when

\[
d(v)=d(w)\ \text{and}\ f(w)<f(v)\quad\Longrightarrow\quad
\sum_{u\in N(v)}c(f(u))\leq\sum_{u\in N(w)}c(f(u)).
\]

## The existence results

Theorem 1. For every finite simple graph and every strictly increasing function
\(c:I_n\to\mathbb R\), there is a labelling that respects both the degree order
and the equal-degree neighbour-sum order for \(c\).

Corollary 2. For every finite simple undirected graph \(G=(V,E)\), with
\(n=|V|\), there exists a labelling \(f:V\to I_n\) such that, for all
\(v,w\in V\),

\[
d(v)<d(w)\quad\Longrightarrow\quad f(w)<f(v),
\]

and

\[
d(v)=d(w)\ \text{and}\ f(w)<f(v)\quad\Longrightarrow\quad
\sum_{u\in N(v)}2^{f(u)}\leq\sum_{u\in N(w)}2^{f(u)}.
\]


## Proof of Theorem 1

Consider the set \(\mathcal A\) of all labellings that respect the degree
order. This set is nonempty: order the vertices by decreasing degree, choose any
order within each degree class, and assign the labels in \(I_n\) in that
order. The set \(\mathcal A\) is finite.

For \(g\in\mathcal A\), define the edge potential

\[
\Phi(g)=\sum_{\{x,y\}\in E}c(g(x))c(g(y)).
\]

Since \(\mathcal A\) is finite and nonempty, choose \(f\in\mathcal A\) for which
\(\Phi(f)\) is minimal.

Take vertices \(v,w\) with \(d(v)=d(w)\) and \(f(w)<f(v)\). Strict monotonicity
gives \(c(f(w))<c(f(v))\). Let \(f'\) be obtained from \(f\) by exchanging the
labels of \(v\) and \(w\). Because \(v\) and \(w\) have equal degree, \(f'\) is
still in \(\mathcal A\).

To calculate the change in the potential, the edge set \(E\) splits into the edges
incident with neither \(v\) nor \(w\) (\(E_0\)), with \(v\) only (\(E_v\)), with
\(w\) only (\(E_w\)), and with both (\(E_{vw}\)). Edges in \(E_0\) are unchanged
by the exchange. If \(\{v,w\}\in E\), then \(E_{vw}=\{\{v,w\}\}\) and its
contribution is \(c(f(v))c(f(w))\) both before and after the exchange. If
\(\{v,w\}\notin E\), then \(E_{vw}\) is empty.

The contributions from \(E_v\) and \(E_w\) therefore give

\[
\begin{aligned}
\Phi(f')-\Phi(f)
={}&\bigl(c(f(w))-c(f(v))\bigr)
\sum_{u\in N(v)\setminus\{w\}}c(f(u))\\
&+\bigl(c(f(v))-c(f(w))\bigr)
\sum_{u\in N(w)\setminus\{v\}}c(f(u))\\
=&\bigl(c(f(v))-c(f(w))\bigr)
\left(\sum_{u\in N(w)\setminus\{v\}}c(f(u))
-\sum_{u\in N(v)\setminus\{w\}}c(f(u))\right).
\end{aligned}
\]

Minimality of \(f\) implies \(\Phi(f')-\Phi(f)\geq0\). Since
\(c(f(v))-c(f(w))>0\), it follows that

\[
\sum_{u\in N(v)\setminus\{w\}}c(f(u))
\leq\sum_{u\in N(w)\setminus\{v\}}c(f(u)).
\]

We distinguish whether \(v\) and \(w\) are adjacent.

**Adjacent case.** If \(v\) and \(w\) are adjacent, then

\[
\begin{aligned}
\sum_{u\in N(v)}c(f(u))
&=\sum_{u\in N(v)\setminus\{w\}}c(f(u))+c(f(w))\\
&\leq\sum_{u\in N(w)\setminus\{v\}}c(f(u))+c(f(v))\\
&=\sum_{u\in N(w)}c(f(u)).
\end{aligned}
\]

Thus the required inequality holds in the adjacent case.

**Non-adjacent case.** If \(v\) and \(w\) are not adjacent, then

\[
\sum_{u\in N(v)}c(f(u))
=\sum_{u\in N(v)\setminus\{w\}}c(f(u))
\leq\sum_{u\in N(w)\setminus\{v\}}c(f(u))
=\sum_{u\in N(w)}c(f(u)).
\]

Thus the required inequality holds in the non-adjacent case. Therefore the chosen
labelling proves Theorem 1.

## Proof of Corollary 2

Apply Theorem 1 to the function

\[
c(i)=2^i\qquad(i\in I_n).
\]

This function is strictly increasing, and the resulting inequalities are exactly
those in Corollary 2.

## Scope and convention

The results assert existence only; they do not assert uniqueness or a method for
constructing a particular labelling. The alternative convention uses the labels
\(1,\ldots,n\) and assigns weight \(2^k\) to label \(k\). Translating between this
convention and \(I_n\) multiplies or divides every neighbour sum by \(2\). The
factor is common to all vertices and positive, so both ordering conditions are
unchanged. The two conventions are therefore equivalent.
