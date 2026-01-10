(** ROM32K: 32K read-only memory for instruction storage *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; address : 'a [@bits 15]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
