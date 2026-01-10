(** Or gate: if (a or b) out = 1, else out = 0 *)

open! Core
open! Hardcaml

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
