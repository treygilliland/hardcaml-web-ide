(* Mux: if (sel) out = b, else out = a
   
   Hierarchical implementation: Mux = Or(And(a, Not(sel)), And(b, sel)) *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let not_sel = not_ scope i.sel in
  let a_and_not_sel = and_ scope i.a not_sel in
  let b_and_sel = and_ scope i.b i.sel in
  { out = or_ scope a_and_not_sel b_and_sel }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux" create

