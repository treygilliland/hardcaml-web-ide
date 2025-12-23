(* 8-way Or gate: out = in[0] Or in[1] Or ... Or in[7] *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 8] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  { out = reduce ~f:( |: ) (bits_lsb i.a) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"or8way" create

