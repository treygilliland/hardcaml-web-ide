(* Or gate: if (a or b) out = 1, else out = 0
   
   Hierarchical implementation: Or = Nand(Not(a), Not(b)) *)

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

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let not_a = not_ scope i.a in
  let not_b = not_ scope i.b in
  { out = Nand.nand not_a not_b }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"or" create

