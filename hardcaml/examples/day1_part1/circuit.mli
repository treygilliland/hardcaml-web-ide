(** Day 1 Part 1 - Advent of Code 2025
   
    A dial with positions 0-99 (circular) starts at 50.
    Process L/R rotation commands and count how many times the dial lands on 0. *)

open! Core
open! Hardcaml

val position_bits : int
val value_bits : int
val count_bits : int
val initial_position : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; direction : 'a
    ; value : 'a
    ; command_valid : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { zero_count : 'a
    ; position : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
