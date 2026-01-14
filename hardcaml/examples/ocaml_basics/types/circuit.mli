(** Hello Types: Demonstrates basic OCaml types, functions, and records *)

open! Core
open! Hardcaml

val width : int

module I : sig
  type 'a t = { data : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
