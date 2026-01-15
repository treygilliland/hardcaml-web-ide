(** Hardcaml Playground *)

open! Core
open! Hardcaml

(* Module signature for input *)
module I : sig
  type 'a t = { a : 'a; b : 'a }
  [@@deriving hardcaml]
end

(* Module signature for output *)
module O : sig
  type 'a t = { out : 'a }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
