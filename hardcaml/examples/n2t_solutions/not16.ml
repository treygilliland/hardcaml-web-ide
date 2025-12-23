(* 16-bit Not gate: for i = 0..15: out[i] = Not(in[i])
   
   Hierarchical implementation: Apply Not to each bit of the 16-bit input. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let bits = bits_lsb i.a in
  let inverted = List.map bits ~f:(not_ scope) in
  { out = concat_lsb inverted }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"not16" create

