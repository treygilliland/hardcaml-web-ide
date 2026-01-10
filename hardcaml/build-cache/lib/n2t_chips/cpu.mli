(** CPU: The Hack Central Processing Unit
    Executes instructions according to the Hack machine language specification *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inM : 'a [@bits 16]
    ; instruction : 'a [@bits 16]
    ; reset : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { outM : 'a [@bits 16]
    ; writeM : 'a
    ; addressM : 'a [@bits 15]
    ; pc : 'a [@bits 15]
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
