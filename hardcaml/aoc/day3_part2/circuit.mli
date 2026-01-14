(** Day 3 Part 2 - Advent of Code 2025
   
    Find 12 sequential maximum digits from each line, building a 12-digit number.
    For each line:
    1. Start at position -1, N = 11
    2. Repeat 12 times:
       - Find max digit in range [i+1, len-N]
       - Update i to position of that max
       - Add digit × 10^N to result
       - Decrement N
    3. Accumulate line results *)

open! Core
open! Hardcaml

val digit_bits : int
val pos_bits : int
val max_line_length : int
val num_digits : int
val digit_count_bits : int
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
