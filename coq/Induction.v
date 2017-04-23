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
Admitted.