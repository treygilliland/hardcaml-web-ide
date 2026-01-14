(** Day 3 Part 1 - Advent of Code 2025
   
    For each line of digits:
    1. Find x = max digit in positions 0 to n-2 (exclude last)
    2. Find i = first position where digit equals x
    3. Find y = max digit from position i+1 to n-1 (include last)
    4. Add x * 10 + y to running total *)

open! Core
open! Hardcaml

val digit_bits : int
val pos_bits : int
val result_bits : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; digit : 'a
    ; digit_valid : 'a
    ; end_of_line : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { result : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
