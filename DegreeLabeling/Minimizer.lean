import DegreeLabeling.SwapPotential
import Mathlib.Tactic

namespace DegreeLabeling

/-!
# The minimising labelling

This module uses the swap formula and potential minimality to prove the ordered
neighbour-sum condition for a degree-respecting minimiser.
-/

universe u

variable {V : Type u} [Fintype V]

/-- A potential-minimising admissible labelling orders the neighbour sums among
equal-degree vertices. -/
theorem minimizer_respectsEqualDegreeNeighborSums
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (hc : StrictMono c)
    (f : AdmissibleLabeling G)
    (hmin :
      ∀ g : AdmissibleLabeling G,
        edgePotential G c f.1 ≤ edgePotential G c g.1) :
    RespectsEqualDegreeNeighborSums G c f.1 := by
  classical
  intro v w hdeg hlabel
  have hvw_ne : v ≠ w := by
    intro h
    subst w
    exact (Nat.lt_irrefl _ hlabel).elim
  have horder : RespectsDegreeOrder G (swapVertices f.1 v w) :=
    respectsDegreeOrder_swapVertices G f.1 f.2 hdeg
  let f' : AdmissibleLabeling G := ⟨swapVertices f.1 v w, horder⟩
  have hpot := hmin f'
  have hdiff :
      0 ≤ edgePotential G c (swapVertices f.1 v w) - edgePotential G c f.1 :=
    sub_nonneg.mpr hpot
  rw [edgePotential_swapVertices_sub G c f.1 hvw_ne] at hdiff
  have hweight : c (f.1 w) < c (f.1 v) := hc hlabel
  have hsum :
      neighborSumExcept G c f.1 v w ≤ neighborSumExcept G c f.1 w v := by
    nlinarith
  by_cases hadj : G.Adj v w
  · simp only [weightedNeighborSum]
    calc
      (∑ u ∈ G.neighborFinset v, c (f.1 u)) =
          (∑ u ∈ (G.neighborFinset v).erase w, c (f.1 u)) + c (f.1 w) :=
        (Finset.sum_erase_add (G.neighborFinset v) (fun u => c (f.1 u))
          ((G.mem_neighborFinset v w).mpr hadj)).symm
      _ ≤ (∑ u ∈ (G.neighborFinset w).erase v, c (f.1 u)) + c (f.1 v) :=
        add_le_add hsum (le_of_lt hweight)
      _ = ∑ u ∈ G.neighborFinset w, c (f.1 u) :=
        Finset.sum_erase_add (G.neighborFinset w) (fun u => c (f.1 u))
          ((G.mem_neighborFinset w v).mpr (SimpleGraph.Adj.symm hadj))
  · simp only [weightedNeighborSum]
    have hvw_not : w ∉ G.neighborFinset v := by
      intro hw
      exact hadj ((G.mem_neighborFinset v w).mp hw)
    have hwv_not : v ∉ G.neighborFinset w := by
      intro hv
      exact hadj (SimpleGraph.Adj.symm ((G.mem_neighborFinset w v).mp hv))
    simp only [neighborSumExcept] at hsum
    rw [Finset.erase_eq_self.mpr hvw_not, Finset.erase_eq_self.mpr hwv_not] at hsum
    exact hsum

end DegreeLabeling
