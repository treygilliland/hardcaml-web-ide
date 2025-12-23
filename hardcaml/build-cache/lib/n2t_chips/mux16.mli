(** 16-bit multiplexor: for i = 0..15: if (sel = 0) out[i] = a[i], else out[i] = b[i] *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

