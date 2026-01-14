(** Computer: The Hack computer, consisting of CPU, ROM and RAM *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; reset : 'a
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { pc : 'a [@bits 15]
    ; addressM : 'a [@bits 15]
    ; outM : 'a [@bits 16]
    ; writeM : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
