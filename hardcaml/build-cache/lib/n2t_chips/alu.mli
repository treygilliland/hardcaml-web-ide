(** ALU (Arithmetic Logic Unit): Computes various functions of x and y
   
    Control bits:
    - zx: if 1 then x = 0
    - nx: if 1 then x = !x
    - zy: if 1 then y = 0
    - ny: if 1 then y = !y
    - f:  if 1 then out = x + y, else out = x & y
    - no: if 1 then out = !out
   
    Output flags:
    - zr: if out = 0 then zr = 1, else zr = 0
    - ng: if out < 0 then ng = 1, else ng = 0 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { x : 'a [@bits 16]
    ; y : 'a [@bits 16]
    ; zx : 'a
    ; nx : 'a
    ; zy : 'a
    ; ny : 'a
    ; f : 'a
    ; no : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { out : 'a [@bits 16]
    ; zr : 'a
    ; ng : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

