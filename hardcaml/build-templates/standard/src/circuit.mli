(* Stub circuit interface - will be overwritten by user code *)
open! Hardcaml

module I : sig
  type 'a t = { clock : 'a } [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
