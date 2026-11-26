# DegreeLabeling

For every finite simple graph with \(n\) vertices, the development proves that a
bijection from its vertices to \(n\) ordered labels can order vertices by decreasing
degree and, within each degree class, order weighted neighbour sums for every
strictly increasing real weight function. It also proves the powers-of-two case,
using \(2^{f(u)}\) for the label \(f(u)\) of a neighbour \(u\).

## Paper

Toshio Ishikawa and Tomoki Uda, *Degree-respecting labellings with ordered
neighbour sums*,
[arXiv:2611.34269](https://arxiv.org/abs/2611.34269) [math.CO], 2026.

~~~bibtex
@misc{ishikawa-uda-2026,
  author        = {Ishikawa, Toshio and Uda, Tomoki},
  title         = {Degree-respecting labellings with ordered neighbour sums},
  year          = {2026},
  eprint        = {2611.34269},
  archivePrefix = {arXiv},
  primaryClass  = {math.CO},
  url           = {https://arxiv.org/abs/2611.34269}
}
~~~

The source of the paper is in docs/paper/; citation metadata is in
[CITATION.cff](CITATION.cff).

## Public results

| Mathematical statement | Lean declaration |
|---|---|
| A finite simple graph has a degree-respecting labelling that orders weighted neighbour sums for every strictly increasing real weight function. | DegreeLabeling.exists_degreeOrdered_labeling_strictMonoWeights |
| A finite simple graph has a degree-respecting labelling whose powers-of-two neighbour sums are ordered within each degree class. | DegreeLabeling.exists_degreeOrdered_labeling_powersOfTwo |
| A degree-respecting labelling exists. | DegreeLabeling.admissibleLabeling_nonempty |
| The edge potential attains a minimum on the finite admissible type. | DegreeLabeling.exists_minimal_edgePotential |
| Exchanging equal-degree vertices preserves the degree-order condition. | DegreeLabeling.respectsDegreeOrder_swapVertices |
| The edge-potential change under a label exchange equals the two omitted-neighbour sums formula. | DegreeLabeling.edgePotential_swapVertices_sub |
| A potential-minimising admissible labelling orders equal-degree neighbour sums. | DegreeLabeling.minimizer_respectsEqualDegreeNeighborSums |

## Build

~~~sh
scripts/bootstrap.sh
scripts/check.sh
~~~

The check runs the repository guards, builds the library, audits the pinned
declarations with #print axioms, and checks theorem coverage.

## Trust footprint

The accepted declarations contain no sorry. Their axiom closures are contained
in {propext, Classical.choice, Quot.sound}. The live audit reads
scripts/print_axioms.lean; the coverage check fails if a public theorem is not
pinned there.

## Repository layout

- DegreeLabeling/ contains the definitions and proof modules.
- DegreeLabeling.lean is the library root.
- scripts/ contains the gate and its supporting checks.
- docs/math/degree_labeling.md contains the mathematical exposition.
- docs/paper/ contains the source of the paper.
- docs/references.bib contains the bibliography.
- .claude/skills/ and .claude/hooks/ contain the repository workflow guidance.

The workflow is described in [docs/orchestration.md](docs/orchestration.md).

## License

Apache-2.0; see [LICENSE](LICENSE).
