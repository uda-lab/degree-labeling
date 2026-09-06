-- DegreeLabeling: library root. Every library module is imported here so that
-- `import DegreeLabeling` (as used by scripts/print_axioms.lean and the coverage guard)
-- reaches all of them. A module missing here fails scripts/check-axiom-coverage.sh.
import DegreeLabeling.Basic
import DegreeLabeling.Contract
import DegreeLabeling.EdgePotential
import DegreeLabeling.SwapPotential
import DegreeLabeling.Minimizer
import DegreeLabeling.Admissible

namespace DegreeLabeling

universe u

variable {V : Type u} [Fintype V]

theorem exists_degreeOrdered_labeling_strictMonoWeights
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (hc : StrictMono c) :
    HasDegreeOrderedNeighborSumLabeling G c := by
  obtain ⟨f, hmin⟩ := exists_minimal_edgePotential G c
    (admissibleLabeling_nonempty G)
  exact ⟨f.1, f.2, minimizer_respectsEqualDegreeNeighborSums G c hc f hmin⟩

theorem exists_degreeOrdered_labeling_powersOfTwo
    (G : SimpleGraph V) :
    HasDegreeOrderedNeighborSumLabeling G
      (fun i : Fin (Fintype.card V) =>
        (2 : ℝ) ^ (i.val + 1)) := by
  apply exists_degreeOrdered_labeling_strictMonoWeights G
  exact (pow_right_strictMono₀ one_lt_two).comp (by
    intro i j hij
    exact Nat.add_lt_add_right (Fin.mk_lt_mk.mp hij) 1)

end DegreeLabeling
