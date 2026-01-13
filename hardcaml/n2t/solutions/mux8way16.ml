(* 8-way 16-bit multiplexor:
   out = a if sel = 000
         b if sel = 001
         c if sel = 010
         d if sel = 011
         e if sel = 100
         f if sel = 101
         g if sel = 110
         h if sel = 111
   
   Hierarchical implementation: Two Mux4Way16 + one Mux16. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; c : 'a [@bits 16]
    ; d : 'a [@bits 16]
    ; e : 'a [@bits 16]
    ; f : 'a [@bits 16]
    ; g : 'a [@bits 16]
    ; h : 'a [@bits 16]
    ; sel : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let sel01 = select i.sel ~high:1 ~low:0 in
  let sel2 = bit i.sel ~pos:2 in
  let abcd = N2t_chips.mux4way16_ scope i.a i.b i.c i.d sel01 in
  let efgh = N2t_chips.mux4way16_ scope i.e i.f i.g i.h sel01 in
  { out = N2t_chips.mux16_ scope abcd efgh sel2 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux8way16" create
