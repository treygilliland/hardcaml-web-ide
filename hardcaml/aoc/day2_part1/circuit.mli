(** Day 2 Part 1 - Advent of Code 2025
   
    Find numbers in ranges where:
    - The digit count is even
    - The first half of digits equals the second half
    
    Circuit receives pre-extracted BCD digits and checks the mirror pattern. *)

open! Core
open! Hardcaml

val max_digits : int
val digit_bits : int
val count_bits : int
val value_bits : int
val sum_bits : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; digits : 'a
    ; digit_count : 'a
    ; value : 'a
    ; number_valid : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { sum : 'a
    ; match_count : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
