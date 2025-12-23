(** Multiplexor: if (sel = 0) out = a, else out = b *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

