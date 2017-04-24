Theorem plus_n_0 : forall n : nat,
	n = n + 0.

Proof.
	induction n as [| n' IHn'].
	- reflexivity.
	- simpl. rewrite <- IHn'. reflexivity.
Qed.

(*******************)
(* basic_induction *)
(*******************)

Theorem mult_0_r : forall n : nat,
	n * 0 = 0.

Proof.
	induction n as [| n' IHn'].
	- reflexivity.
	- simpl. rewrite -> IHn'. reflexivity.
Qed.

Theorem plus_n_Sm : forall n m : nat,
	S (n + m) = n + (S m).

Proof.
	intros n m.
	induction n as [| n' IHn'].
	- reflexivity.
	- simpl. rewrite -> IHn'. reflexivity.
Qed.

Theorem plus_comm : forall n m : nat,
	n + m = m + n.

Proof.
	intros n m.
	induction n as [| n' IHn'].
	- simpl. rewrite <- plus_n_0. reflexivity.
	- simpl. rewrite <- plus_n_Sm. rewrite -> IHn'. reflexivity.
Qed.

Theorem plus_assoc : forall n m p : nat,
	n + (m + p) = (n + m) + p.

Proof.
	intros n m p.
	induction n as [| n' IHn'].
	- reflexivity.
	- simpl. rewrite -> IHn'. reflexivity.
Qed.

(***************)
(* double_plus *)
(***************)

Fixpoint double (n : nat) : nat :=
	match n with
		| O    => O
		| S n' => S (S (double n'))
	end.

Lemma double_plus : forall n : nat,
	double n = n + n.

Proof.
	induction n as [| n' IHn'].
	- reflexivity.
	- simpl. rewrite -> IHn'. rewrite -> plus_n_Sm. reflexivity.
Qed.

(***********)
(* evenb_S *)
(***********)

Fixpoint evenb (n : nat) : bool :=
	match n with
		| O        => true
		| S O      => false
		| S (S n') => evenb n'
	end.

Lemma evenb_lemma : forall n : nat,
	evenb (S (S n)) = evenb n.

Proof.
	destruct n.
	- reflexivity.
	- reflexivity.
Qed.

Lemma negb_lemma : forall b : bool,
	negb (negb b) = b.

Proof.
	destruct b.
	- reflexivity.
	- reflexivity.
Qed.

Theorem evenb_S : forall n : nat,
	evenb (S n) = negb (evenb n).

Proof.
	induction n as [| n' IHn'].
	- reflexivity.
	- rewrite -> evenb_lemma. rewrite -> IHn'.
		rewrite -> negb_lemma. reflexivity.
Qed.