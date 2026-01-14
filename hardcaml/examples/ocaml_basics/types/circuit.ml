(* Hello Types: Demonstrates basic OCaml types, functions, and records
   
   This example shows:
   - let bindings
   - type annotations
   - record types
   - simple functions
   - Hardcaml module structure *)

open! Core
open! Hardcaml
open! Signal

(* Constants with type annotations *)
let width : int = 8

(* Input interface - a record type *)
module I = struct
  type 'a t =
    { data : 'a [@bits width]  (* 8-bit input signal *)
    }
  [@@deriving hardcaml]
end

(* Output interface - another record type *)
module O = struct
  type 'a t =
    { out : 'a [@bits width]  (* 8-bit output signal *)
    }
  [@@deriving hardcaml]
end

(* Helper function with type annotations *)
let pass_through (input : Signal.t) : Signal.t =
  input

(* Main circuit creation function *)
let create _scope (i : _ I.t) : _ O.t =
  (* Simple pass-through: output equals input *)
  { out = pass_through i.data }

(* Hierarchical wrapper for Hardcaml *)
let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"types" create
