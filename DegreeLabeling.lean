-- DegreeLabeling: library root. Every library module is imported here so that
-- `import DegreeLabeling` (as used by scripts/print_axioms.lean and the coverage guard)
-- reaches all of them. A module missing here fails scripts/check-axiom-coverage.sh.
import DegreeLabeling.Basic
import DegreeLabeling.Contract
import DegreeLabeling.EdgePotential
import DegreeLabeling.SwapPotential
import DegreeLabeling.Minimizer
import DegreeLabeling.Admissible
