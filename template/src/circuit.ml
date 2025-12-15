(* Placeholder circuit - will be replaced by user code *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { clock : 'a; clear : 'a }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { output : 'a }
  [@@deriving hardcaml]
end

let create _scope ({ clock = _; clear = _ } : _ I.t) : _ O.t =
  { output = Signal.gnd }
;;
