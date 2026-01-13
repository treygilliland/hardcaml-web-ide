(* Day 3 Part 1 - Advent of Code 2025
   
   TODO: Implement the circuit for this puzzle.
   This is a placeholder with generic I/O. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; input_valid : 'a
    ; input_data : 'a [@bits 32]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { result : 'a [@bits 64]
    ; done_ : 'a
    }
  [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let _ = scope, i in
  { O.result = Signal.zero 64; done_ = Signal.gnd }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day3_part1" create
;;
