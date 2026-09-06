import Mathlib.Combinatorics.SimpleGraph.Finite
import Mathlib.Data.Fintype.Perm
import Mathlib.Data.Real.Basic

open scoped BigOperators

/-!
# DegreeLabeling.Contract

This module freezes the transparent statement contract for the source-faithful
T1 and T2 results. The future public theorem signatures are:

```lean
theorem exists_degreeOrdered_labeling_strictMonoWeights
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (hc : StrictMono c) :
    HasDegreeOrderedNeighborSumLabeling G c

theorem exists_degreeOrdered_labeling_powersOfTwo
    (G : SimpleGraph V) :
    HasDegreeOrderedNeighborSumLabeling G
      (fun i : Fin (Fintype.card V) =>
        (2 : ℝ) ^ (i.val + 1))
```
-/

namespace DegreeLabeling

universe u

variable {V : Type u} [Fintype V]

/-- A source labelling `V → {1, ..., |V|}`, represented with zero-based `Fin`. -/
abbrev Labeling (V : Type u) [Fintype V] : Type u :=
  V ≃ Fin (Fintype.card V)

/-- The source's one-based label corresponding to the zero-based `Fin` value. -/
def sourceLabel (f : Labeling V) (v : V) : ℕ :=
  (f v).val + 1

/--
The source sum `Sᶜ_v = ∑_{u ∼ v} c_{f(u)}`.
For `i : Fin (Fintype.card V)`, `c i` represents source weight `c_{i.val + 1}`.
-/
noncomputable def weightedNeighborSum
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V)
    (v : V) : ℝ := by
  classical
  exact ∑ u ∈ G.neighborFinset v, c (f u)

/-- Lower degree receives the larger source label. -/
noncomputable def RespectsDegreeOrder
    (G : SimpleGraph V) (f : Labeling V) : Prop := by
  classical
  exact ∀ v w : V,
    G.degree v < G.degree w →
      sourceLabel f v > sourceLabel f w

/--
Among equal-degree vertices, the larger-labelled vertex has the smaller-or-equal
weighted neighbour sum.
-/
noncomputable def RespectsEqualDegreeNeighborSums
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V) : Prop := by
  classical
  exact ∀ v w : V,
    (G.degree v = G.degree w ∧
      sourceLabel f v > sourceLabel f w) →
    weightedNeighborSum G c f v ≤ weightedNeighborSum G c f w

/-- The exact source conclusion for a fixed weight family `c`. -/
noncomputable def HasDegreeOrderedNeighborSumLabeling
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ) : Prop :=
  ∃ f : Labeling V,
    RespectsDegreeOrder G f ∧
    RespectsEqualDegreeNeighborSums G c f

/-- The finite type `𝓕` of degree-respecting bijections. -/
abbrev AdmissibleLabeling (G : SimpleGraph V) :=
  { f : Labeling V // RespectsDegreeOrder G f }

end DegreeLabeling
