(** Day 4 Part 2 - Advent of Code 2025
   
    TODO: Implement the circuit for this puzzle. *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; input_valid : 'a
    ; input_data : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { result : 'a
    ; done_ : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
