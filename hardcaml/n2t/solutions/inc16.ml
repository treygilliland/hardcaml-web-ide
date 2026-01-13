(* 16-bit Incrementer: out = in + 1
   
   Hierarchical implementation using Add16 with constant 1 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { inp : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  { out = add16_ scope i.inp (one 16) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"inc16" create
