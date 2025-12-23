(** Full Adder: Computes the sum of three bits
    sum = LSB of a + b + c
    carry = MSB of a + b + c *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { sum : 'a
    ; carry : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

