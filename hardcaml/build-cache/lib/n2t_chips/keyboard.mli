(** Keyboard: Memory-mapped keyboard input
    Returns the currently pressed key scancode, or 0 if no key is pressed *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

