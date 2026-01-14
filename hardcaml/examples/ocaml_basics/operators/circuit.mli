(** Hello Operators: Demonstrates Hardcaml infix operators *)

open! Core
open! Hardcaml

module I : sig
  type 'a t = { a : 'a; b : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { and_out : 'a
    ; or_out : 'a
    ; xor_out : 'a
    ; not_a : 'a
    ; sum : 'a
    ; equal : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
