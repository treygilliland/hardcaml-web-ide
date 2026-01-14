(* 16-bit Not gate: for i = 0..15: out[i] = Not(in[i]) *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  { out = ~:(i.a) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"not16" create
