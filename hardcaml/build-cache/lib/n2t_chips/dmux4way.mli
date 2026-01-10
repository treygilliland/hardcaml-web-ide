(** 4-way demultiplexor:
    [a, b, c, d] = [in, 0, 0, 0] if sel = 00
                   [0, in, 0, 0] if sel = 01
                   [0, 0, in, 0] if sel = 10
                   [0, 0, 0, in] if sel = 11 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
