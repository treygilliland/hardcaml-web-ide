(** NAND gate - the fundamental building block of the Hack chipset *)

open! Core
open! Hardcaml

(** Primitive NAND operation: out = ~(a & b) *)
val nand : Signal.t -> Signal.t -> Signal.t

module I : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

