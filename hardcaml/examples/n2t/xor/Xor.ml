(* Xor gate: if ((a and Not(b)) or (Not(a) and b)) out = 1, else out = 0
   
   Implement using only Nand gates from the N2t library.
   Hint: XOR = (a NAND (a NAND b)) NAND (b NAND (a NAND b)) *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let open N2t in
  let nand_ab = nand_ i.a i.b in
  let a_nand_nandab = nand_ i.a nand_ab in
  let b_nand_nandab = nand_ i.b nand_ab in
  { out = nand_ a_nand_nandab b_nand_nandab }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"xor" create
;;

