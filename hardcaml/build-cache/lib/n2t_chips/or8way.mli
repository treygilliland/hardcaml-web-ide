(** 8-way Or gate: out = in[0] Or in[1] Or ... Or in[7] *)

open! Core
open! Hardcaml

module I : sig
  type 'a t = { a : 'a [@bits 8] } [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

