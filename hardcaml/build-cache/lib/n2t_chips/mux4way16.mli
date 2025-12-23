(** 4-way 16-bit multiplexor:
    out = a if sel = 00
          b if sel = 01
          c if sel = 10
          d if sel = 11 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; c : 'a [@bits 16]
    ; d : 'a [@bits 16]
    ; sel : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

