(** Demultiplexor:
    [a, b] = [in, 0] if sel = 0
             [0, in] if sel = 1 *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { inp : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
