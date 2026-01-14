(* Stub circuit module - will be overwritten by user code *)
open! Hardcaml

module I = struct
  type 'a t = { clock : 'a } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create (_scope : Scope.t) (_i : Signal.t I.t) : Signal.t O.t = { out = Signal.gnd }
