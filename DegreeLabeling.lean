import DegreeLabeling.Defs
import DegreeLabeling.EdgePotential
import DegreeLabeling.SwapPotential
import DegreeLabeling.Minimizer
import DegreeLabeling.Admissible

/-!
# Degree-respecting labellings

This root module collects the definitions and lemmas proving the existence of
degree-respecting labellings with ordered weighted neighbour sums.
-/

namespace DegreeLabeling

universe u

variable {V : Type u} [Fintype V]

/-- Every finite simple graph has a degree-respecting labelling whose weighted
neighbour sums are ordered among equal-degree vertices for any strictly
increasing real weight function. -/
theorem exists_degreeOrdered_labeling_strictMonoWeights
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (hc : StrictMono c) :
    HasDegreeOrderedNeighborSumLabeling G c := by
  obtain ⟨f, hmin⟩ := exists_minimal_edgePotential G c
    (admissibleLabeling_nonempty G)
  exact ⟨f.1, f.2, minimizer_respectsEqualDegreeNeighborSums G c hc f hmin⟩

open scoped Classical in
/-- Every finite simple graph has a zero-based labelling satisfying the degree
order and the corresponding natural-number powers-of-two inequalities. -/
theorem exists_degreeOrdered_labeling_powersOfTwo
    (G : SimpleGraph V) :
    ∃ f : V ≃ Fin (Fintype.card V),
      RespectsDegreeOrder G f ∧
        ∀ v w : V,
          G.degree v = G.degree w →
          f w < f v →
          (∑ u ∈ G.neighborFinset v, 2 ^ (f u : ℕ)) ≤
            ∑ u ∈ G.neighborFinset w, 2 ^ (f u : ℕ) := by
  let c : Fin (Fintype.card V) → ℝ := fun i => (2 : ℝ) ^ (i : ℕ)
  have hc : StrictMono c := by
    exact (pow_right_strictMono₀ one_lt_two).comp (by
      intro i j hij
      exact Fin.mk_lt_mk.mp hij)
  obtain ⟨f, hdegree, hsum⟩ :=
    exists_degreeOrdered_labeling_strictMonoWeights G c hc
  refine ⟨f, hdegree, ?_⟩
  intro v w hdeg hlabel
  have hreal := hsum v w hdeg hlabel
  change (∑ u ∈ G.neighborFinset v, (2 : ℝ) ^ (f u : ℕ)) ≤
    ∑ u ∈ G.neighborFinset w, (2 : ℝ) ^ (f u : ℕ) at hreal
  exact_mod_cast hreal

end DegreeLabeling
