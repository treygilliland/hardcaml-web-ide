(* 8-way 16-bit multiplexor:
   out = a if sel = 000
         b if sel = 001
         c if sel = 010
         d if sel = 011
         e if sel = 100
         f if sel = 101
         g if sel = 110
         h if sel = 111 *)

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

let create _scope (i : _ I.t) : _ O.t =
  { out = mux i.sel [ i.a; i.b; i.c; i.d; i.e; i.f; i.g; i.h ] }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux8way16" create
