(* Dmux: if (sel) {a, b} = {0, inp}, else {a, b} = {inp, 0}
   
   Hierarchical implementation: a = And(inp, Not(sel)), b = And(inp, sel) *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let not_sel = not_ scope i.sel in
  { a = and_ scope i.inp not_sel
  ; b = and_ scope i.inp i.sel
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux" create
