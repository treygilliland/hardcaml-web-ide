(* Xor gate: if (a xor b) out = 1, else out = 0
   
   Hierarchical implementation: Xor = Or(And(a, Not(b)), And(Not(a), b)) *)

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
  let a_and_not_b = and_ scope i.a not_b in
  let not_a_and_b = and_ scope not_a i.b in
  { out = or_ scope a_and_not_b not_a_and_b }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"xor" create

