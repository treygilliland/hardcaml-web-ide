(** 16-bit Incrementer: out = in + 1 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t = { inp : 'a [@bits 16] } [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

