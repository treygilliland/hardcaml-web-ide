(** 8-way 16-bit multiplexor:
    out = a if sel = 000
          b if sel = 001
          c if sel = 010
          d if sel = 011
          e if sel = 100
          f if sel = 101
          g if sel = 110
          h if sel = 111 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; c : 'a [@bits 16]
    ; d : 'a [@bits 16]
    ; e : 'a [@bits 16]
    ; f : 'a [@bits 16]
    ; g : 'a [@bits 16]
    ; h : 'a [@bits 16]
    ; sel : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

