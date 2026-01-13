(* 4-way 16-bit multiplexor:
   out = a if sel = 00
         b if sel = 01
         c if sel = 10
         d if sel = 11
   
   Hierarchical implementation: Two-level Mux16 tree. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; c : 'a [@bits 16]
    ; d : 'a [@bits 16]
    ; sel : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let sel0 = bit i.sel ~pos:0 in
  let sel1 = bit i.sel ~pos:1 in
  let ab = N2t_chips.mux16_ scope i.a i.b sel0 in
  let cd = N2t_chips.mux16_ scope i.c i.d sel0 in
  { out = N2t_chips.mux16_ scope ab cd sel1 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux4way16" create
