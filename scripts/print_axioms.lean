-- Live axiom audit input, consumed by scripts/check-axioms.sh.
-- Run after `lake build`:   lake env lean scripts/print_axioms.lean
--
-- Append one `#print axioms` line for every public theorem a PR claims as a result
-- (scripts/check-axiom-coverage.sh fails the gate when one is missing).
-- APPEND-ONLY: removing or renaming a line is a `needs-decision` change.
import DegreeLabeling

#print axioms DegreeLabeling.exists_minimal_edgePotential
#print axioms DegreeLabeling.edgePotential_swapVertices_sub
#print axioms DegreeLabeling.respectsDegreeOrder_swapVertices
#print axioms DegreeLabeling.admissibleLabeling_nonempty
#print axioms DegreeLabeling.minimizer_respectsEqualDegreeNeighborSums
#print axioms DegreeLabeling.exists_degreeOrdered_labeling_strictMonoWeights
#print axioms DegreeLabeling.exists_degreeOrdered_labeling_powersOfTwo
