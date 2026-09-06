import DegreeLabeling.EdgePotential
import Mathlib.Tactic

open scoped BigOperators

namespace DegreeLabeling

universe u

variable {V : Type u} [Fintype V]

noncomputable def swapVertices
    (f : Labeling V) (v w : V) : Labeling V := by
  classical
  exact (Equiv.swap v w).trans f

open scoped Classical in
theorem respectsDegreeOrder_swapVertices
    (G : SimpleGraph V)
    (f : Labeling V)
    {v w : V}
    (hf : RespectsDegreeOrder G f)
    (hdeg : G.degree v = G.degree w) :
    RespectsDegreeOrder G (swapVertices f v w) := by
  classical
  intro x y hxy
  have hdegree_swap (z : V) : G.degree (Equiv.swap v w z) = G.degree z := by
    by_cases hzv : z = v
    · subst z
      rw [Equiv.swap_apply_left]
      exact hdeg.symm
    · by_cases hzw : z = w
      · subst z
        rw [Equiv.swap_apply_right]
        exact hdeg
      · rw [Equiv.swap_apply_of_ne_of_ne hzv hzw]
  have hxy' : G.degree (Equiv.swap v w x) < G.degree (Equiv.swap v w y) := by
    rw [hdegree_swap, hdegree_swap]
    exact hxy
  have h := hf (Equiv.swap v w x) (Equiv.swap v w y) hxy'
  simpa [sourceLabel, swapVertices] using h

noncomputable def neighborSumExcept
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V)
    (v excluded : V) : ℝ := by
  classical
  exact ∑ u ∈ (G.neighborFinset v).erase excluded, c (f u)

theorem edgePotential_swapVertices_sub
    (G : SimpleGraph V)
    (c : Fin (Fintype.card V) → ℝ)
    (f : Labeling V)
    {v w : V}
    (hvw : v ≠ w) :
    edgePotential G c (swapVertices f v w) -
        edgePotential G c f =
      (c (f v) - c (f w)) *
        (neighborSumExcept G c f w v -
          neighborSumExcept G c f v w) := by
  classical
  letI : ∀ x : V, Fintype (G.neighborSet x) := fun x => Subtype.fintype _
  let E := @SimpleGraph.edgeFinset V G G.fintypeEdgeSet
  let Iv := G.incidenceFinset v
  let Iw := G.incidenceFinset w
  let E0 := E \ (Iv ∪ Iw)
  let Ev := Iv \ Iw
  let Ew := Iw \ Iv
  let Eb := Iv ∩ Iw
  let q : Sym2 V → ℝ := fun e =>
    edgeWeight c (swapVertices f v w) e - edgeWeight c f e
  have hIv : Iv ⊆ E := by
    exact G.incidenceFinset_subset v
  have hIw : Iw ⊆ E := by
    exact G.incidenceFinset_subset w
  have hEv : Ev ⊆ Iv := by
    intro e he
    exact (Finset.mem_sdiff.mp he).1
  have hEw : Ew ⊆ Iw := by
    intro e he
    exact (Finset.mem_sdiff.mp he).1
  have hEbv : Eb ⊆ Iv := by
    intro e he
    exact (Finset.mem_inter.mp he).1
  have hEbw : Eb ⊆ Iw := by
    intro e he
    exact (Finset.mem_inter.mp he).2
  have hpartition : E = E0 ∪ (Ev ∪ (Ew ∪ Eb)) := by
    ext e
    simp only [E0, Ev, Ew, Eb, Finset.mem_union, Finset.mem_sdiff, Finset.mem_inter]
    constructor
    · intro he
      by_cases hev : e ∈ Iv
      · by_cases hew : e ∈ Iw
        · exact Or.inr (Or.inr (Or.inr ⟨hev, hew⟩))
        · exact Or.inr (Or.inl ⟨hev, hew⟩)
      · by_cases hew : e ∈ Iw
        · exact Or.inr (Or.inr (Or.inl ⟨hew, hev⟩))
        · exact Or.inl ⟨he, by simp [hev, hew]⟩
    · intro he
      rcases he with he | he | he | he
      · exact he.1
      · exact hIv he.1
      · exact hIw he.1
      · exact hIv he.1
  have hdisj0 (s : Finset (Sym2 V)) (hs : s ⊆ Iv ∪ Iw) : Disjoint E0 s := by
    rw [Finset.disjoint_left]
    intro e he0 hes
    exact (Finset.mem_sdiff.mp he0).2 (hs hes)
  have hdisjvw : Disjoint Ev Ew := by
    rw [Finset.disjoint_left]
    intro e hev hew
    exact (Finset.mem_sdiff.mp hev).2 (Finset.mem_sdiff.mp hew).1
  have hdisjvb : Disjoint Ev Eb := by
    rw [Finset.disjoint_left]
    intro e hev heb
    exact (Finset.mem_sdiff.mp hev).2 (Finset.mem_inter.mp heb).2
  have hdisjwb : Disjoint Ew Eb := by
    rw [Finset.disjoint_left]
    intro e hew heb
    exact (Finset.mem_sdiff.mp hew).2 (Finset.mem_inter.mp heb).1
  have hdisjvwb : Disjoint Ev (Ew ∪ Eb) := by
    rw [Finset.disjoint_union_right]
    exact ⟨hdisjvw, hdisjvb⟩
  have hsum_incidence_erase (x y : V) (hxy : x ≠ y) (r : Sym2 V → ℝ) :
      (∑ e ∈ G.incidenceFinset x \ G.incidenceFinset y, r e) =
        ∑ u ∈ (G.neighborFinset x).erase y, r s(x, u) := by
    symm
    apply Finset.sum_bij (fun u _ => s(x, u))
    · intro u hu
      have hu' := Finset.mem_erase.mp hu
      have hxu : G.Adj x u := (G.mem_neighborFinset x u).mp hu'.2
      apply Finset.mem_sdiff.mpr
      constructor
      · exact (G.mem_incidenceFinset x _).mpr ((G.mem_incidenceSet x u).mpr hxu)
      · intro he
        have he' : s(x, u) ∈ G.incidenceSet y := (G.mem_incidenceFinset y _).mp he
        rcases (Sym2.mem_iff.mp he'.2) with h | h
        · exact (hxy h.symm).elim
        · exact hu'.1 h.symm
    · intro u₁ hu₁ u₂ hu₂ heq
      rw [Sym2.eq_iff] at heq
      rcases heq with ⟨_, h⟩ | ⟨h, _⟩
      · exact h
      · have hxu₂ : G.Adj x u₂ :=
          (G.mem_neighborFinset x u₂).mp (Finset.mem_erase.mp hu₂).2
        exact ((G.irrefl (h ▸ hxu₂)).elim)
    · intro e he
      have he_x := (Finset.mem_sdiff.mp he).1
      have hx : x ∈ e := ((G.mem_incidenceFinset x e).mp he_x).2
      rcases Sym2.mem_iff_exists.mp hx with ⟨u, rfl⟩
      have hxu : G.Adj x u :=
        (G.mem_incidenceSet x u).mp ((G.mem_incidenceFinset x _).mp he_x)
      have huy : u ≠ y := by
        intro huy
        apply (Finset.mem_sdiff.mp he).2
        subst u
        exact (G.mem_incidenceFinset y _).mpr (G.mk'_mem_incidenceSet_right_iff.mpr hxu)
      exact ⟨u, Finset.mem_erase.mpr ⟨huy, (G.mem_neighborFinset x u).mpr hxu⟩, rfl⟩
    · intro u hu
      rfl
  have hqv : ∑ e ∈ Ev, q e =
      (c (f w) - c (f v)) * neighborSumExcept G c f v w := by
    rw [show Ev = G.incidenceFinset v \ G.incidenceFinset w by rfl,
      hsum_incidence_erase v w hvw]
    simp_rw [neighborSumExcept]
    rw [Finset.mul_sum]
    have hpoint : ∀ u ∈ (G.neighborFinset v).erase w,
        q s(v, u) = (c (f w) - c (f v)) * c (f u) := by
      intro u hu
      have hu' := Finset.mem_erase.mp hu
      have huv : G.Adj v u := (G.mem_neighborFinset v u).mp hu'.2
      have huv_ne : u ≠ v := by
        intro h
        exact G.irrefl (h ▸ huv)
      simp [q, edgeWeight, swapVertices, Equiv.swap_apply_of_ne_of_ne huv_ne hu'.1]
      ring
    exact Finset.sum_congr rfl hpoint
  have hqw : ∑ e ∈ Ew, q e =
      (c (f v) - c (f w)) * neighborSumExcept G c f w v := by
    rw [show Ew = G.incidenceFinset w \ G.incidenceFinset v by rfl,
      hsum_incidence_erase w v hvw.symm]
    simp_rw [neighborSumExcept]
    rw [Finset.mul_sum]
    have hpoint : ∀ u ∈ (G.neighborFinset w).erase v,
        q s(w, u) = (c (f v) - c (f w)) * c (f u) := by
      intro u hu
      have hu' := Finset.mem_erase.mp hu
      have huw : G.Adj w u := (G.mem_neighborFinset w u).mp hu'.2
      have huw_ne : u ≠ w := by
        intro h
        exact G.irrefl (h ▸ huw)
      simp [q, edgeWeight, swapVertices, Equiv.swap_apply_of_ne_of_ne hu'.1 huw_ne]
      ring
    exact Finset.sum_congr rfl hpoint
  have hq0 : ∑ e ∈ E0, q e = 0 := by
    apply Finset.sum_eq_zero
    intro e he
    revert he
    refine Sym2.inductionOn e ?_
    intro x y hey
    have he' := (Finset.mem_sdiff.mp hey).2
    have hxy : G.Adj x y :=
      G.mem_edgeSet.mp (G.mem_edgeFinset.mp (Finset.mem_sdiff.mp hey).1)
    have hnotv : s(x, y) ∉ Iv := by
      intro h
      exact he' (Finset.mem_union.mpr (Or.inl h))
    have hnotw : s(x, y) ∉ Iw := by
      intro h
      exact he' (Finset.mem_union.mpr (Or.inr h))
    have hxv : x ≠ v := by
      intro hx
      apply hnotv
      subst x
      exact (G.mem_incidenceFinset v _).mpr ((G.mem_incidenceSet v y).mpr hxy)
    have hy_v : y ≠ v := by
      intro hy
      apply hnotv
      subst y
      exact (G.mem_incidenceFinset v _).mpr (G.mk'_mem_incidenceSet_right_iff.mpr hxy)
    have hxw : x ≠ w := by
      intro hx
      apply hnotw
      subst x
      exact (G.mem_incidenceFinset w _).mpr ((G.mem_incidenceSet w y).mpr hxy)
    have hy_w : y ≠ w := by
      intro hy
      apply hnotw
      subst y
      exact (G.mem_incidenceFinset w _).mpr (G.mk'_mem_incidenceSet_right_iff.mpr hxy)
    simp [q, edgeWeight, swapVertices,
      Equiv.swap_apply_of_ne_of_ne hxv hxw,
      Equiv.swap_apply_of_ne_of_ne hy_v hy_w]
  have hqb : ∑ e ∈ Eb, q e = 0 := by
    by_cases hadj : G.Adj v w
    · have hEb : Eb = {s(v, w)} := by
        ext e
        constructor
        · intro he
          have he' : e ∈ G.incidenceSet v ∩ G.incidenceSet w :=
            ⟨(G.mem_incidenceFinset v e).mp (Finset.mem_inter.mp he).1,
              (G.mem_incidenceFinset w e).mp (Finset.mem_inter.mp he).2⟩
          rw [G.incidenceSet_inter_incidenceSet_of_adj hadj] at he'
          exact Finset.mem_singleton.mpr (by simpa using he')
        · intro he
          have he' : e = s(v, w) := Finset.mem_singleton.mp he
          subst e
          exact Finset.mem_inter.mpr ⟨
            (G.mem_incidenceFinset v _).mpr ((G.mem_incidenceSet v w).mpr hadj),
            (G.mem_incidenceFinset w _).mpr (G.mk'_mem_incidenceSet_right_iff.mpr hadj)⟩
      rw [hEb]
      simp [q, edgeWeight, swapVertices, hvw]
      ring
    · have hEb : Eb = ∅ := by
        ext e
        constructor
        · intro he
          exfalso
          apply hadj
          exact G.adj_of_mem_incidenceSet hvw
            ((G.mem_incidenceFinset v e).mp (Finset.mem_inter.mp he).1)
            ((G.mem_incidenceFinset w e).mp (Finset.mem_inter.mp he).2)
        · intro he
          simp at he
      rw [hEb]
      simp
  have htotal : ∑ e ∈ E, q e =
      (c (f v) - c (f w)) *
        (neighborSumExcept G c f w v - neighborSumExcept G c f v w) := by
    rw [hpartition,
      Finset.sum_union (hdisj0 (Ev ∪ (Ew ∪ Eb)) (by
        intro e he
        rcases Finset.mem_union.mp he with he | he
        · exact Finset.mem_union.mpr (Or.inl (hEv he))
        · rcases Finset.mem_union.mp he with he | he
          · exact Finset.mem_union.mpr (Or.inr (hEw he))
          · exact Finset.mem_union.mpr (Or.inr (hEbw he)))),
      Finset.sum_union hdisjvwb, Finset.sum_union hdisjwb]
    rw [hq0, hqv, hqw, hqb]
    ring
  rw [edgePotential, edgePotential, ← Finset.sum_sub_distrib]
  simpa [E, q] using htotal

end DegreeLabeling
