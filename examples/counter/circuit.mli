(** Simple 8-bit counter circuit *)

open! Core
open! Hardcaml

val counter_bits : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; enable : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { count : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
