(* 8-way Or gate: out = in[0] Or in[1] Or ... Or in[7]
   
   Hierarchical implementation: Chain Or gates together. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 8] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let bits = bits_lsb i.a in
  let result = List.reduce_exn bits ~f:(or_ scope) in
  { out = result }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"or8way" create

