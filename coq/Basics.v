(* Enumerated Type *)
Inductive bool : Type :=
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

Infix "&&" := andb.

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
		| O => 1
		(* | S n' => mult n (factorial n') *)
		| S n' => n * (factorial n')
	end.

Example ex_factorial1 : (factorial 0) = 1.
Proof. simpl. reflexivity. Qed.
Example ex_factorial2 : (factorial 1) = 1.
Proof. simpl. reflexivity. Qed.
Example ex_factorial3 : (factorial 5) = 120.
Proof. simpl. reflexivity. Qed.