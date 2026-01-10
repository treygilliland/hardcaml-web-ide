(** Half Adder: Computes the sum of two bits
    sum = LSB of a + b
    carry = MSB of a + b *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a
    ; b : 'a
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
