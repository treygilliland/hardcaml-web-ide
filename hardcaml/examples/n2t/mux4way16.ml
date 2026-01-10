(* 4-way 16-bit multiplexor:
   out = a if sel = 00
         b if sel = 01
         c if sel = 10
         d if sel = 11
   
   Hint: Use two Mux16 to select between (a,b) and (c,d) using sel[0],
   then use another Mux16 to select between results using sel[1]. *)

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement Mux4Way16 *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux4way16" create
