import Mathlib.Combinatorics.SimpleGraph.Finite
import Mathlib.Data.Fintype.Perm
import Mathlib.Data.Real.Basic

open scoped BigOperators

/-!
# Degree-respecting labellings and neighbour sums

This module defines zero-based bijective labellings, weighted neighbour sums, the
two ordering conditions, and the finite type of labellings satisfying the degree
condition.
-/

namespace DegreeLabeling

universe u

variable {V : Type u} [Fintype V]

/-- A zero-based bijective labelling of the vertices by `0, ..., |V| - 1`. -/
abbrev Labeling (V : Type u) [Fintype V] : Type u :=
  V ≃ Fin (Fintype.card V)

/-- The sum of the weights assigned to the neighbours of a vertex. -/
noncomputable def weightedNeighborSum
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V)
    (v : V) : ℝ := by
  classical
  exact ∑ u ∈ G.neighborFinset v, c (f u)

/-- A labelling assigns a larger label to every vertex of smaller degree. -/
noncomputable def RespectsDegreeOrder
    (G : SimpleGraph V) (f : Labeling V) : Prop := by
  classical
  exact ∀ v w : V,
    G.degree v < G.degree w →
      f w < f v

/-- For equal degrees, the larger-labelled vertex has the smaller neighbour sum. -/
noncomputable def RespectsEqualDegreeNeighborSums
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V) : Prop := by
  classical
  exact ∀ v w : V,
    G.degree v = G.degree w →
    f w < f v →
    weightedNeighborSum G c f v ≤ weightedNeighborSum G c f w

/-- Existence of a labelling satisfying both ordering conditions for `c`. -/
noncomputable def HasDegreeOrderedNeighborSumLabeling
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ) : Prop :=
  ∃ f : Labeling V,
    RespectsDegreeOrder G f ∧
    RespectsEqualDegreeNeighborSums G c f

/-- The finite type of labellings that respect the degree order. -/
abbrev AdmissibleLabeling (G : SimpleGraph V) :=
  { f : Labeling V // RespectsDegreeOrder G f }

end DegreeLabeling
