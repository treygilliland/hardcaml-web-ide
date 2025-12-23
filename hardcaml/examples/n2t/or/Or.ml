(* Or gate: if (a or b) out = 1, else out = 0
   
   Implement using only Nand gates from the N2t library.
   Hint: Use De Morgan's law: a OR b = NOT(NOT(a) AND NOT(b)) *)

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
  let not_a = nand_ i.a i.a in
  let not_b = nand_ i.b i.b in
  { out = nand_ not_a not_b }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"or" create
;;

