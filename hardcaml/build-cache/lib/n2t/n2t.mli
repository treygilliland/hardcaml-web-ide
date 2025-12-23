(** Nand2Tetris Hack Chipset for Hardcaml

    This library provides the primitive Nand gate that all other gates
    are built from, following the Nand2Tetris curriculum. *)

open! Core
open! Hardcaml

(** Primitive NAND operation: out = ~(a & b) *)
val nand_ : Signal.t -> Signal.t -> Signal.t

(** NAND gate chip - the fundamental building block *)
module Nand : sig
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
end

