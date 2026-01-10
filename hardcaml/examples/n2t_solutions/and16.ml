(* 16-bit And gate: for i = 0..15: out[i] = a[i] And b[i]
   
   Hierarchical implementation: Apply And to each pair of bits. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let a_bits = bits_lsb i.a in
  let b_bits = bits_lsb i.b in
  let anded = List.map2_exn a_bits b_bits ~f:(and_ scope) in
  { out = concat_lsb anded }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"and16" create
