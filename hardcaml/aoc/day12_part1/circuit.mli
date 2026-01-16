(** Day 12 Part 1 - Advent of Code 2025
   
    Count regions where total shape area fits in the grid.
    Each shape is 9 cells (3x3), so: total_count * 9 <= width * height *)

open! Core
open! Hardcaml

val width_bits : int
val height_bits : int
val count_bits : int
val result_bits : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; problem_valid : 'a
    ; width : 'a
    ; height : 'a
    ; total_count : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { possible_count : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
