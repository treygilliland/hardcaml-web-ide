(* And gate: if (a and b) out = 1, else out = 0
   
   Implement using only Nand gates from the N2t library.
   Hint: And is the inverse of Nand. *)

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
  { out = nand_ nand_ab nand_ab }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"and" create
;;

