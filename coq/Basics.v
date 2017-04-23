(* Enumerated Type *)
(*Inductive bool : Type :=
	(* Constructors *)
	| false : bool
	| true  : bool.

Definition negb (b : bool) : bool :=
	match b with
		| false => true
		| true  => false
	end.

(* Definition andb (b1 : bool) (b2 : bool) : bool := *)
Definition andb (b1 b2 : bool) : bool :=
	match b1 with
		| true  => b2
		| false => false
	end.

Infix "&&" := andb.*)

(*********)
(* nandb *)
(*********)

Definition nandb (b1 b2 : bool) : bool :=
	negb (b1 && b2).

Example ex_nandb1 : (nandb false false) = true.
Proof. simpl. reflexivity. Qed.
Example ex_nandb2 : (nandb false true ) = true.
Proof. simpl. reflexivity. Qed.
Example ex_nandb3 : (nandb true  false) = true.
Proof. simpl. reflexivity. Qed.
Example ex_nandb4 : (nandb true  true ) = false.
Proof. simpl. reflexivity. Qed.

(*********)
(* andb3 *)
(*********)

Definition andb3 (b1 b2 b3 : bool) : bool :=
	b1 && b2 && b3.

Example ex_andb3_1 : (andb3 false false false) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_2 : (andb3 false false true ) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_3 : (andb3 false true  false) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_4 : (andb3 false true  true ) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_5 : (andb3 true  false false) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_6 : (andb3 true  false true ) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_7 : (andb3 true  true  false) = false.
Proof. simpl. reflexivity. Qed.
Example ex_andb3_8 : (andb3 true  true  true ) = true.
Proof. simpl. reflexivity. Qed.

(*************)
(* factorial *)
(*************)

(* Fixpoint: recursive definition *)
Fixpoint factorial (n : nat) : nat :=
	match n with
		| O    => 1
		(* | S n' => mult n (factorial n') *)
		| S n' => n * (factorial n')
	end.

Example ex_factorial1 : (factorial 0) = 1.
Proof. simpl. reflexivity. Qed.
Example ex_factorial2 : (factorial 1) = 1.
Proof. simpl. reflexivity. Qed.
Example ex_factorial3 : (factorial 5) = 120.
Proof. simpl. reflexivity. Qed.

(***********)
(* blt_nat *)
(***********)

Fixpoint be_nat (n m : nat) : bool :=
	match n with
		| O    => match m with
		          	| O    => true
		          	| S m' => false
		          end
		| S n' => match m with
		          	| O    => true
		          	| S m' => be_nat n' m'
		          end
	end.

Fixpoint ble_nat (n m : nat) : bool :=
	match n with
		| O    => true
		| S n' => match m with
		          	| O    => false
		          	| S m' => ble_nat n' m'
		          end
	end.

Definition blt_nat (n m : nat) : bool :=
	(negb (be_nat n m)) && (ble_nat n m).

Example ex_blt_nat_1 : (blt_nat 2 2) = false.
Proof. simpl. reflexivity. Qed.
Example ex_blt_nat_2 : (blt_nat 2 4) = true.
Proof. simpl. reflexivity. Qed.
Example ex_blt_nat_3 : (blt_nat 4 2) = false.
Proof. simpl. reflexivity. Qed.

(********************)
(* plus_id_exercise *)
(********************)

(* -> "implies" *)

Theorem plus_id_exercise : forall n m o : nat,
	n = m -> m = o -> n + m = m + o.

Proof.
	(* Move n, m, o from goal to assumptions *)
	intros n m o.
	(* Move hypotheses into context *)
	intros H H'.
	(* Rewrite goal using hypotheses from left to right *)
	rewrite -> H.
	rewrite -> H'.
	(* Check both sides for equal values *)
	reflexivity.
Qed.

(************)
(* mult_S_1 *)
(************)

Theorem mult_S_1 : forall n m : nat,
	m = S n ->
	m * (1 + n) = m * m.

Proof.
	(* Move n, m into context *)
	intros n m.
	(* Move hypothesis into context *)
	intros H.
	rewrite -> H.
	reflexivity.
Qed.

(*******************)
(* andb_true_elim2 *)
(*******************)

Theorem andb_true_elim2 : forall b c : bool,
	andb b c = true -> c = true.

Proof.
	intros b. destruct b.
	- destruct c.
		+ simpl. reflexivity.
		+ simpl. intros H. rewrite -> H. reflexivity.
	- destruct c.
		+ simpl. reflexivity.
		+ simpl. intros H. rewrite -> H. reflexivity.
Qed.

(* Alternative:
Proof.
	intros [] [].
	- simpl. intros H. rewrite -> H. reflexivity.
	- reflexivity.
	- simpl. intros H. rewrite -> H. reflexivity.
	- reflexivity. Qed.*)

(********************)
(* zero_nbeq_plus_1 *)
(********************)

Theorem zero_nbeq_plus_1 : forall n : nat,
	be_nat 0 (n + 1) = false.

Proof.
	intros [|n].
	- reflexivity.
	- simpl. reflexivity.
Qed.

(*********************)
(* boolean_functions *)
(*********************)

Theorem identity_fn_applied_twice :
	forall (f : bool -> bool),
	(forall (x : bool), f x = x) ->
	forall (b : bool), f (f b) = b.

Proof.
	intros f H.
	intros [].
	- rewrite -> H. rewrite -> H. reflexivity.
	- rewrite -> H. rewrite -> H. reflexivity.
Qed.

Theorem negation_fn_applied_twice :
	forall (f : bool -> bool),
	(forall (x : bool), f x = negb x) ->
	forall (b : bool), f (f b) = b.

Proof.
	intros f H.
	intros [].
	- rewrite -> H. rewrite -> H. reflexivity.
	- rewrite -> H. rewrite -> H. reflexivity.
Qed.

(***************)
(* andb_eq_orb *)
(***************)

Theorem andb_eq_orb :
	forall (b c : bool),
	(andb b c = orb b c) ->
	b = c.

Proof.
	intros b c.
	destruct b.
	- simpl. intros H. rewrite -> H. reflexivity.
	- simpl. intros H. rewrite -> H. reflexivity.
Qed.

(**********)
(* binary *)
(**********)