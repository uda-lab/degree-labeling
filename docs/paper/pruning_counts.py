#!/usr/bin/env python3
"""Exact counts for the pruning rules of the hydrocarbon enumeration (Issue #45).

Every count below is a number of adjacency matrices: symmetric 0/1 matrices of
size n with zero diagonal, i.e. labelled graphs on I_n = {0, ..., n-1}. These
are distinct matrices, not graph-labelling pairs: an unlabelled graph G gives
n!/|Aut(G)| distinct matrices, since labellings that differ by an automorphism
give the same matrix. The last column counts isomorphism classes (unlabelled
graphs) instead.

Columns, for each n:
  all        every adjacency matrix: 2^(n choose 2)
  skeleton   the graph is connected and every degree is at most 4
  degree     skeleton, and degrees do not increase with the label (rule 1)
  rows       degree, and among equal degrees the row values sum_j a_ij 2^j do
             not increase with the label (rule 2)
  classes    isomorphism classes of skeleton graphs

The class count is computed from the matrices in the rows column, using a
canonical form: the lexicographically largest tuple of row values over all
relabellings that keep degrees non-increasing. Since every class has at least
one matrix in the rows column (Corollary 2 of the paper), this gives the number
of skeleton classes; --check verifies that claim directly by canonicalising
every skeleton matrix, and compares the class counts with those reported by
Smooth Pudding (2024).

Usage:
  python3 pruning_counts.py [--max-n N] [--format text|latex] [--check]
"""

import argparse
import itertools
import sys

# Isomorphism classes of connected graphs with maximum degree at most 4, as
# reported in the enumeration of Smooth Pudding (2024) for n = 2, ..., 10.
REPORTED_CLASSES = {2: 1, 3: 2, 4: 6, 5: 21, 6: 78, 7: 353, 8: 1929, 9: 12207,
                    10: 89402}

MAX_DEGREE = 4


def matrices(n):
    """Yield the row values of every adjacency matrix of size n."""
    pairs = list(itertools.combinations(range(n), 2))
    for mask in range(1 << len(pairs)):
        rows = [0] * n
        for k, (i, j) in enumerate(pairs):
            if mask >> k & 1:
                rows[i] |= 1 << j
                rows[j] |= 1 << i
        yield rows


def degrees(rows):
    return [bin(r).count("1") for r in rows]


def connected(rows):
    n = len(rows)
    if n == 0:
        return True
    seen, frontier = 1, 1
    while frontier:
        new = 0
        for i in range(n):
            if frontier >> i & 1:
                new |= rows[i]
        frontier = new & ~seen
        seen |= new
    return seen == (1 << n) - 1


def is_skeleton(rows, deg):
    return max(deg, default=0) <= MAX_DEGREE and connected(rows)


def rule_degree(deg):
    return all(deg[i] >= deg[i + 1] for i in range(len(deg) - 1))


def rule_rows(rows, deg):
    return all(
        deg[i] != deg[i + 1] or rows[i] >= rows[i + 1] for i in range(len(rows) - 1)
    )


def relabel(rows, order):
    """Row values after giving label k to the vertex order[k]."""
    pos = {v: k for k, v in enumerate(order)}
    out = []
    for v in order:
        r = 0
        for u in range(len(rows)):
            if rows[v] >> u & 1:
                r |= 1 << pos[u]
        out.append(r)
    return tuple(out)


def canonical(rows, deg):
    """Largest row tuple over relabellings that keep degrees non-increasing."""
    blocks = []
    for d in sorted(set(deg), reverse=True):
        blocks.append([v for v in range(len(rows)) if deg[v] == d])
    best = None
    for parts in itertools.product(*(itertools.permutations(b) for b in blocks)):
        cand = relabel(rows, [v for part in parts for v in part])
        if best is None or cand > best:
            best = cand
    return best


def count(n, check=False):
    total = skeleton = degree = survive = 0
    classes = set()
    skeleton_classes = set() if check else None
    for rows in matrices(n):
        total += 1
        deg = degrees(rows)
        if not is_skeleton(rows, deg):
            continue
        skeleton += 1
        if check:
            skeleton_classes.add(canonical(rows, deg))
        if not rule_degree(deg):
            continue
        degree += 1
        if not rule_rows(rows, deg):
            continue
        survive += 1
        classes.add(canonical(rows, deg))
    if check and skeleton_classes != classes:
        sys.exit(f"check failed: n={n}: a class has no surviving matrix")
    return {"n": n, "all": total, "skeleton": skeleton, "degree": degree,
            "rows": survive, "classes": len(classes)}


COLUMNS = ["n", "all", "skeleton", "degree", "rows", "classes"]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--max-n", type=int, default=7)
    ap.add_argument("--format", choices=["text", "latex"], default="text")
    ap.add_argument("--check", action="store_true",
                    help="verify that every skeleton class survives both rules "
                         "and compare class counts with the reported ones")
    args = ap.parse_args(argv)

    results = [count(n, args.check) for n in range(2, args.max_n + 1)]
    if args.check:
        for r in results:
            want = REPORTED_CLASSES.get(r["n"])
            if want is not None and r["classes"] != want:
                sys.exit(f"check failed: n={r['n']}: {r['classes']} classes, "
                         f"reported {want}")

    if args.format == "latex":
        for r in results:
            print(" & ".join(str(r[c]) for c in COLUMNS) + r" \\")
    else:
        print(" ".join(f"{c:>9}" for c in COLUMNS))
        for r in results:
            print(" ".join(f"{r[c]:>9}" for c in COLUMNS))
    if args.check:
        print("check: OK", file=sys.stderr)


if __name__ == "__main__":
    main()
