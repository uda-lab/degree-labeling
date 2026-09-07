import DegreeLabeling.Defs

open scoped BigOperators

namespace DegreeLabeling

/-!
# The edge potential

This module defines the potential obtained by summing the products of endpoint
weights over the unordered edges and proves that it has a minimum on the finite
type of degree-respecting labellings.
-/

universe u

variable {V : Type u} [Fintype V]

/-- The product of the weights at the endpoints of an unordered pair. -/
def edgeWeight
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V) : Sym2 V → ℝ :=
  Sym2.lift
    ⟨fun x y => c (f x) * c (f y),
      fun x y => mul_comm _ _⟩

/-- The sum of endpoint-weight products over all edges of the graph. -/
noncomputable def edgePotential
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V) : ℝ := by
  classical
  exact ∑ e ∈ G.edgeFinset, edgeWeight c f e

/-- The edge potential attains a minimum on the finite admissible type. -/
theorem exists_minimal_edgePotential
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (hF : Nonempty (AdmissibleLabeling G)) :
    ∃ f : AdmissibleLabeling G,
      ∀ g : AdmissibleLabeling G,
        edgePotential G c f.1 ≤ edgePotential G c g.1 := by
  classical
  have huniv : (Finset.univ : Finset (AdmissibleLabeling G)).Nonempty := by
    rcases hF with ⟨f⟩
    exact ⟨f, Finset.mem_univ f⟩
  obtain ⟨f, hf, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset (AdmissibleLabeling G))
      (fun f => edgePotential G c f.1) huniv
  refine ⟨f, ?_⟩
  intro g
  exact hmin g (Finset.mem_univ g)

end DegreeLabeling
