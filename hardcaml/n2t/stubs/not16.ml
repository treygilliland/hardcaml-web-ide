(* 16-bit Not gate: for i = 0..15: out[i] = Not(in[i])
   
   Implement by applying Not to each bit of the 16-bit input.
   Hint: You can use bitwise NOT on the entire signal at once. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement Not16 *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"not16" create
