(** * Pushouts defined in terms of colimits *)
(** ** Contents
- Definition of pushouts
- Coincides with the direct definition
*)
Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.limits.pushouts.

(** * Definition of pushouts in terms of colimits *)
Section def_po.

  Variable C : precategory.
  Variable hs: has_homsets C.

  Inductive three := One | Two | Three.

  Definition pushout_graph : graph.
  Proof.
    exists three.
    exact (fun a b =>
             match (a,b) with
             | (Two ,One) => unit
             | (Two, Three) => unit
             | _ => empty
             end).
  Defined.

  Definition pushout_diagram {a b c : C} (f : C ⟦a,b⟧) (g : C⟦a,c⟧) :
    diagram pushout_graph C.
  Proof.
    exists (fun x => match x with
             | One => b
             | Two => a
             | Three => c end).
    intros u v e.
    induction u; induction v; simpl; try induction e; assumption.
  Defined.

  Definition PushoutCocone {a b c : C} (f : C ⟦a,b⟧) (g : C⟦a,c⟧)
             (d : C) (f' : C ⟦b, d⟧) (g' : C ⟦c,d⟧)
             (H : f ;; f' = g ;; g')
    : cocone (pushout_diagram f g) d.
  Proof.
    simple refine (mk_cocone _ _  ).
    - intro v; induction v; simpl; try assumption.
      apply (f ;; f').
    - intros u v e;
        induction u; induction v; try induction e; simpl.
      + apply idpath.
      + apply (!H).
  Defined.

  Definition isPushout {a b c d : C} (f : C ⟦a, b⟧) (g : C ⟦a, c⟧)
             (i1 : C⟦b,d⟧) (i2 : C⟦c,d⟧) (H : f ;; i1 = g ;; i2) : UU :=
    isColimCocone (pushout_diagram f g) d (PushoutCocone f g d i1 i2 H).

  Definition mk_isPushout {a b c d : C} (f : C ⟦a, b⟧) (g : C ⟦a, c⟧)
             (i1 : C⟦b,d⟧) (i2 : C⟦c,d⟧) (H : f ;; i1 = g ;; i2) :
    (Π e (h : C ⟦b,e⟧) (k : C⟦c,e⟧)(Hk : f ;; h = g ;; k ),
     iscontr (total2 (fun hk : C⟦d,e⟧ => dirprod (i1 ;; hk = h)(i2 ;; hk = k))))
    →
    isPushout f g i1 i2 H.
  Proof.
    intros H' x cx; simpl in *.
    set (H1 := H' x (coconeIn cx One) (coconeIn cx Three)).
    simple refine (let p : f ;; coconeIn cx One = g ;; coconeIn cx Three
                       := _ in _ ).
    - set (H2 := coconeInCommutes cx Two One tt).
    eapply pathscomp0. apply H2.
    clear H2.
    apply pathsinv0.
    apply (coconeInCommutes cx Two Three tt).
  - set (H2 := H1 p).
    simple refine (tpair _ _ _ ).
    + exists (pr1 (pr1 H2)).
      intro v; induction v; simpl.
      * apply (pr1 (pr2 (pr1 H2))).
      * use (pathscomp0 _ (coconeInCommutes cx Two One tt)).
        rewrite <- assoc.
        rewrite (pr1 (pr2 (pr1 H2))).
        apply cancel_postcomposition.
        apply idpath.
      * unfold compose. simpl.
        set (X := pr2 (pr2 (pr1 H2))). simpl in *. apply X.
    +  intro t.
       apply subtypeEquality.
       * simpl.
         intro; apply impred; intro. apply hs.
       * destruct t as [t p0]; simpl.
         apply path_to_ctr.
         { split.
           - apply (p0 One).
           - apply (p0 Three). }
  Defined.

  Definition Pushout {a b c : C} (f : C⟦a, b⟧)(g : C⟦a, c⟧) :=
    ColimCocone (pushout_diagram f g).

  Definition mk_Pushout {a b c : C} (f : C⟦a, b⟧)(g : C⟦a, c⟧)
             (d : C) (i1 : C⟦b,d⟧) (i2 : C ⟦c,d⟧)
             (H : f ;; i1 = g ;; i2)
             (ispo : isPushout f g i1 i2 H)
    : Pushout f g.
  Proof.
    simple refine (tpair _ _ _ ).
    - simple refine (tpair _ _ _ ).
      + apply d.
      + simple refine (PushoutCocone _ _ _ _ _ _ ); assumption.
    - apply ispo.
  Defined.

  Definition Pushouts := Π (a b c : C)(f : C⟦a, b⟧)(g : C⟦a, c⟧),
                          Pushout f g.

  Definition hasPushouts := Π (a b c : C) (f : C⟦a, b⟧) (g : C⟦a, c⟧),
                            ishinh (Pushout f g).


  Definition PushoutObject {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}:
    Pushout f g -> C := fun H => colim H.
  (* Coercion PushoutObject : Pushout >-> ob. *)

  Definition PushoutIn1 {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}
             (Po : Pushout f g) : C⟦b, colim Po⟧ := colimIn Po One.

  Definition PushoutIn2 {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}
             (Po : Pushout f g) : C⟦c, colim Po⟧ := colimIn Po Three.

  Definition PushoutSqrCommutes {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}
             (Po : Pushout f g) :
    f ;; PushoutIn1 Po = g ;; PushoutIn2 Po.
  Proof.
    eapply pathscomp0; [apply (colimInCommutes Po Two One tt) |].
    apply (!colimInCommutes Po Two Three tt) .
  Qed.

  Definition PushoutArrow {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}
             (Po : Pushout f g) e (h : C⟦b, e⟧) (k : C⟦c, e⟧)
             (H : f ;; h = g ;; k)
    : C⟦colim Po, e⟧.
  Proof.
    simple refine (colimArrow _ _ _ ).
    simple refine (mk_cocone _ _ ).
    - intro v; induction v; simpl; try assumption.
      apply (f ;; h).
    - intros u v edg; induction u; induction v; try induction edg; simpl.
      + apply idpath.
      + apply (!H).
  Defined.

  Lemma PushoutArrow_PushoutIn1 {a b c : C} {f : C⟦a, b⟧} {g : C⟦a, c⟧}
        (Po : Pushout f g) e (h : C⟦b , e⟧) (k : C⟦c , e⟧)
        (H : f ;; h = g ;; k) :
    PushoutIn1 Po ;; PushoutArrow Po e h k H = h.
  Proof.
    refine (colimArrowCommutes Po e _ One).
  Qed.

  Lemma PushoutArrow_PushoutIn2 {a b c : C} {f : C⟦a , b⟧} {g : C⟦a , c⟧}
        (Po : Pushout f g) e (h : C⟦b , e⟧) (k : C⟦c , e⟧)
        (H : f ;; h = g ;; k) :
    PushoutIn2 Po ;; PushoutArrow Po e h k H = k.
  Proof.
    refine (colimArrowCommutes Po e _ Three).
  Qed.

  Lemma PushoutArrowUnique {a b c d : C} (f : C⟦a , b⟧) (g : C⟦a , c⟧)
        (Po : Pushout f g)
        e (h : C⟦b , e⟧) (k : C⟦c , e⟧)
        (Hcomm : f ;; h = g ;; k)
        (w : C⟦PushoutObject Po, e⟧)
        (H1 : PushoutIn1 Po ;; w = h) (H2 : PushoutIn2 Po ;; w = k) :
    w = PushoutArrow Po _ h k Hcomm.
  Proof.
    apply path_to_ctr.
    intro v; induction v; simpl; try assumption.
    set (X:= colimInCommutes Po Two Three tt). cbn in X.
    rewrite <- X. rewrite Hcomm. rewrite <- assoc.
    apply cancel_precomposition. apply H2.
  Qed.

  Definition isPushout_Pushout {a b c : C} {f : C⟦a, b⟧}{g : C⟦a, c⟧}
             (P : Pushout f g) :
    isPushout f g (PushoutIn1 P) (PushoutIn2 P) (PushoutSqrCommutes P).
  Proof.
    apply mk_isPushout.
    intros e h k HK.
    simple refine (tpair _ _ _ ).
    - simple refine (tpair _ _ _ ).
      + apply (PushoutArrow P _ h k HK).
      + split.
        * apply PushoutArrow_PushoutIn1.
        * apply PushoutArrow_PushoutIn2.
    - intro t.
      apply subtypeEquality.
      + intro. apply isapropdirprod; apply hs.
      + destruct t as [t p]. simpl.
        refine (PushoutArrowUnique _ _ P _ _ _ _ _ _ _ ).
        * apply e.
        * apply (pr1 p).
        * apply (pr2 p).
  Qed.

  (** ** Pushouts to Pushouts *)

  Definition identity_is_Pushout_input {a b c : C}{f : C⟦a , b⟧} {g : C⟦a , c⟧}
             (Po : Pushout f g) :
    total2 (fun hk : C⟦colim Po, colim Po⟧ =>
              dirprod (PushoutIn1 Po ;; hk = PushoutIn1 Po)
                      (PushoutIn2 Po ;; hk = PushoutIn2 Po)).
  Proof.
    exists (identity (colim Po)).
    apply dirprodpair; apply id_right.
  Defined.

  (* was PushoutArrowUnique *)
  Lemma PushoutArrowUnique' {a b c d : C} (f : C⟦a, b⟧) (g : C⟦a, c⟧)
        (i1 : C⟦b, d⟧) (i2 : C⟦c, d⟧) (H : f ;; i1 = g ;; i2)
        (P : isPushout f g i1 i2 H) e (h : C⟦b, e⟧) (k : C⟦c, e⟧)
        (Hcomm : f ;; h = g ;; k)
        (w : C⟦d, e⟧)
        (H1 : i1 ;; w = h) (H2 : i2 ;; w = k) :
    w =  (pr1 (pr1 (P e (PushoutCocone f g _ h k Hcomm)))).
  Proof.
    apply path_to_ctr.
    intro v; induction v; simpl.
    - assumption.
    - rewrite <- assoc. apply cancel_precomposition. apply H1.
    - assumption.
  Qed.

  Lemma PushoutEndo_is_identity {a b c : C}{f : C⟦a, b⟧} {g : C⟦a, c⟧}
        (Po : Pushout f g) (k : C⟦colim Po , colim Po⟧)
        (kH1 : PushoutIn1 Po ;; k = PushoutIn1 Po)
        (kH2 : PushoutIn2 Po ;; k = PushoutIn2 Po) :
    identity (colim Po) = k.
  Proof.
    apply colim_endo_is_identity.
    intro u; induction u; simpl.
    - apply kH1.
    - unfold colimIn. simpl.
      assert (T:= coconeInCommutes (colimCocone Po) Two Three tt).
      rewrite <- T.
      simpl.
      rewrite <- assoc.
      apply cancel_precomposition.
      apply kH2.
    - assumption.
  Qed.

  Definition from_Pushout_to_Pushout {a b c : C}{f : C⟦a , b⟧} {g : C⟦a , c⟧}
             (Po Po': Pushout f g) : C⟦colim Po , colim Po'⟧.
  Proof.
    apply (PushoutArrow Po (colim Po') (PushoutIn1 _ ) (PushoutIn2 _)).
    exact (PushoutSqrCommutes _ ).
  Defined.

  Lemma are_inverses_from_Pushout_to_Pushout {a b c : C}{f : C⟦a , b⟧}
        {g : C⟦a , c⟧} (Po Po': Pushout f g) :
    is_inverse_in_precat (from_Pushout_to_Pushout Po Po')
                         (from_Pushout_to_Pushout Po' Po).
  Proof.
    split; apply pathsinv0;
      apply PushoutEndo_is_identity;
      rewrite assoc;
      unfold from_Pushout_to_Pushout;
      repeat rewrite PushoutArrow_PushoutIn1;
      repeat rewrite PushoutArrow_PushoutIn2;
      auto.
  Qed.

  Lemma isiso_from_Pushout_to_Pushout {a b c : C}{f : C⟦a , b⟧} {g : C⟦a , c⟧}
        (Po Po': Pushout f g) :
    is_isomorphism (from_Pushout_to_Pushout Po Po').
  Proof.
    apply (is_iso_qinv _ (from_Pushout_to_Pushout Po' Po)).
    apply are_inverses_from_Pushout_to_Pushout.
  Defined.

  Definition iso_from_Pushout_to_Pushout {a b c : C}
             {f : C⟦a , b⟧} {g : C⟦a , c⟧}
             (Po Po': Pushout f g) : iso (colim Po) (colim Po') :=
    tpair _ _ (isiso_from_Pushout_to_Pushout Po Po').


  (** pushout lemma *)

  Section pushout_lemma.

    Variables a b c d e x : C.
    Variables (f : C⟦a , b⟧) (g : C⟦a , c⟧) (h : C⟦b , e⟧) (k : C⟦c , e⟧)
              (i : C⟦b , d⟧) (j : C⟦e , x⟧) (m : C⟦d , x⟧).
    Hypothesis H1 : f ;; h = g ;; k.
    Hypothesis H2 : i ;; m = h ;; j.
    Hypothesis P1 : isPushout _ _ _ _ H1.
    Hypothesis P2 : isPushout _ _ _ _ H2.

    Lemma glueSquares : f ;; i ;; m = g ;; k ;; j.
    Proof.
      rewrite <- assoc.
      rewrite H2.
      rewrite <- H1.
      repeat rewrite <- assoc.
      apply idpath.
    Qed.

    (** TODO: isPushoutGluedSquare : isPushout (f ;; i) g m (k ;; j)
       glueSquares. *)

  End pushout_lemma.

  Section Universal_Unique.

    Hypothesis H : is_category C.

    Lemma inv_from_iso_iso_from_Pushout (a b c : C)
          (f : C⟦a , b⟧) (g : C⟦a , c⟧)
          (Po : Pushout f g) (Po' : Pushout f g):
      inv_from_iso (iso_from_Pushout_to_Pushout Po Po')
      = from_Pushout_to_Pushout Po' Po.
    Proof.
      apply pathsinv0.
      apply inv_iso_unique'.
      set (T:= are_inverses_from_Pushout_to_Pushout Po Po').
      apply (pr1 T).
    Qed.

  End Universal_Unique.

  (** ** Connections to other colimits *)

  Lemma Pushout_from_Colims :
    Colims C -> Pushouts.
  Proof.
    intros H a b c f g; apply H.
  Defined.

End def_po.


(** * Definitions coincide
  In this section we show that pushouts defined as special colimits coincide
  with the direct definition. *)
Section pushout_coincide.

  Variable C : precategory.
  Variable hs: has_homsets C.

  (** ** isPushout *)

  Lemma equiv_isPushout1 {a b c d : C} (f : C ⟦a, b⟧) (g : C ⟦a, c⟧)
        (i1 : C⟦b,d⟧) (i2 : C⟦c,d⟧) (H : f ;; i1 = g ;; i2) :
    limits.pushouts.isPushout f g i1 i2 H -> isPushout C f g i1 i2 H.
  Proof.
    intros X R cc.
    set (XR := limits.pushouts.mk_Pushout f g d i1 i2 H X).
    use unique_exists.

    use (limits.pushouts.PushoutArrow XR).
    exact (coconeIn cc One).
    exact (coconeIn cc Three).
    use (pathscomp0 ((coconeInCommutes cc Two One tt))).
    apply (!(coconeInCommutes cc Two Three tt)).

    intros v. induction v.
    apply (limits.pushouts.PushoutArrow_PushoutIn1 XR).
    cbn. rewrite <- assoc.
    rewrite (limits.pushouts.PushoutArrow_PushoutIn1 XR).
    apply (coconeInCommutes cc Two One tt).

    cbn. apply (limits.pushouts.PushoutArrow_PushoutIn2 XR).
    intros y. cbn beta. apply impred_isaprop. intros t. apply hs.

    intros y T. cbn in T.
    use limits.pushouts.PushoutArrowUnique.
    apply (T One).
    apply (T Three).
  Qed.

  Lemma equiv_isPushout2 {a b c d : C} (f : C⟦a, b⟧) (g : C⟦a, c⟧)
        (i1 : C⟦b,d⟧) (i2 : C⟦c,d⟧) (H : f ;; i1 = g ;; i2) :
    limits.pushouts.isPushout f g i1 i2 H <- isPushout C f g i1 i2 H.
  Proof.
    intros X R k h HH.
    set (XR := mk_Pushout C f g d i1 i2 H X).
    use unique_exists.

    use (PushoutArrow C XR).
    exact k. exact h. exact HH.
    split.
    exact (PushoutArrow_PushoutIn1 C XR R k h HH).
    exact (PushoutArrow_PushoutIn2 C XR R k h HH).
    intros y. cbn beta. apply isapropdirprod; apply hs.

    intros y T. cbn in T.
    use (PushoutArrowUnique C _ _ XR).
    exact R. exact (pr1 T). exact (pr2 T).
  Qed.

  (** ** Pushout *)

  Definition equiv_Pushout1 {a b c : C} (f : C⟦a, b⟧) (g : C⟦a, c⟧) :
    limits.pushouts.Pushout f g -> Pushout C f g.
  Proof.
    intros X.
    exact (mk_Pushout
             C f g X
             (limits.pushouts.PushoutIn1 X)
             (limits.pushouts.PushoutIn2 X)
             (limits.pushouts.PushoutSqrCommutes X)
             (equiv_isPushout1
                _ _ _ _ _
                (limits.pushouts.isPushout_Pushout X))).
  Defined.

  Definition equiv_Pushout2 {a b c : C} (f : C⟦a, b⟧) (g : C⟦a, c⟧) :
    limits.pushouts.Pushout f g <- Pushout C f g.
  Proof.
    intros X.
    exact (limits.pushouts.mk_Pushout
             f g
             (PushoutObject C X)
             (PushoutIn1 C X)
             (PushoutIn2 C X)
             (PushoutSqrCommutes C X)
             (equiv_isPushout2
                _ _ _ _ _
                (isPushout_Pushout C hs X))).
  Defined.

End pushout_coincide.
