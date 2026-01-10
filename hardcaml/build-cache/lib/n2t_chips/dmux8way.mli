(** 8-way demultiplexor:
    [a, b, c, d, e, f, g, h] = [in, 0, 0, 0, 0, 0, 0, 0] if sel = 000
                               [0, in, 0, 0, 0, 0, 0, 0] if sel = 001
                               ... etc *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    ; e : 'a
    ; f : 'a
    ; g : 'a
    ; h : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
