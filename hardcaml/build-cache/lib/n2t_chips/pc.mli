(** PC: 16-bit Program Counter
    if      reset(t): out(t+1) = 0
    else if load(t):  out(t+1) = in(t)
    else if inc(t):   out(t+1) = out(t) + 1
    else              out(t+1) = out(t) *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; inc : 'a
    ; reset : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

