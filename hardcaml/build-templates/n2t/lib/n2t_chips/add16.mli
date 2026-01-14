(** 16-bit Adder: Adds two 16-bit values
    out = a + b (overflow is ignored) *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
