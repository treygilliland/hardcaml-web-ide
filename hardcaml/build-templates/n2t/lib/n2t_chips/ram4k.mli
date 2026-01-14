(** RAM4K: Memory of 4096 16-bit registers *)

open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 12]
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
