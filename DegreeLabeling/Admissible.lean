import DegreeLabeling.Defs
import Mathlib.Data.Fintype.Sort
import Mathlib.Data.Prod.Lex

namespace DegreeLabeling

/-!
# Degree-respecting labellings

This module constructs a bijective labelling that orders vertices by decreasing
degree, with a fixed tie-break to make the construction explicit.
-/

universe u

variable {V : Type u} [Fintype V]

/-- A degree-respecting labelling exists; equal degrees are ordered by a fixed
tie-break. -/
theorem admissibleLabeling_nonempty
    (G : SimpleGraph V) :
    Nonempty (AdmissibleLabeling G) := by
  classical
  let rank : V ≃ Fin (Fintype.card V) := Fintype.equivFin V
  let key : V → (OrderDual ℕ ×ₗ Fin (Fintype.card V)) :=
    fun v => toLex (OrderDual.toDual (G.degree v), rank v)
  have hkey : Function.Injective key := by
    intro v w h
    apply rank.injective
    exact congrArg (fun x : OrderDual ℕ ×ₗ Fin (Fintype.card V) => (ofLex x).2) h
  letI : LinearOrder V := LinearOrder.lift' key hkey
  let e : Fin (Fintype.card V) ≃o V := monoEquivOfFin V rfl
  let f : Labeling V := e.symm.toEquiv
  refine ⟨⟨f, ?_⟩⟩
  intro v w hd
  have hkeylt : key w < key v := by
    change toLex (OrderDual.toDual (G.degree w), rank w) <
      toLex (OrderDual.toDual (G.degree v), rank v)
    exact Prod.Lex.toLex_lt_toLex.mpr (Or.inl hd)
  have hlt : w < v := hkeylt
  have hfl : f w < f v := e.symm.strictMono hlt
  exact hfl

end DegreeLabeling
