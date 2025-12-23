(* 16-bit Incrementer: out = in + 1 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { inp : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  { out = i.inp +: (one 16) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"inc16" create

