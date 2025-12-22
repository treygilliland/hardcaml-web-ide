(* Placeholder circuit interface *)

open! Core
open! Hardcaml

module I : sig
  type 'a t = { clock : 'a; clear : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { output : 'a }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
