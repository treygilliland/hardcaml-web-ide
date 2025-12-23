(* 4-way 16-bit multiplexor:
   out = a if sel = 00
         b if sel = 01
         c if sel = 10
         d if sel = 11 *)

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

let create _scope (i : _ I.t) : _ O.t =
  (* N2T: sel=00->a, sel=01->b, sel=10->c, sel=11->d
     Hardcaml mux: mux sel [case0; case1; case2; ...] selects by index *)
  { out = mux i.sel [ i.a; i.b; i.c; i.d ] }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux4way16" create

