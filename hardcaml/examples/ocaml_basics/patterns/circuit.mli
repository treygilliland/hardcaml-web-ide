(** Hello Patterns: Demonstrates pattern matching and record destructuring *)

open! Core
open! Hardcaml

module I : sig
  type 'a t = { a : 'a; b : 'a; sel : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
