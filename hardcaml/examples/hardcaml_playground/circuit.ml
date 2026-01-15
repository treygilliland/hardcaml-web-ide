(* Hardcaml Playground
 * 
 * Feel free to test out any Hardcaml code you want here!
 * This playground includes a circuit and a test file.
 * Experiment with different Hardcaml features, create your own
 * circuits, and test them out!
 *)

open! Core
open! Hardcaml
open! Signal

(* Example: Simple AND gate *)
module I = struct
  type 'a t = { a : 'a; b : 'a } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  { out = i.a &: i.b }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"circuit" create
