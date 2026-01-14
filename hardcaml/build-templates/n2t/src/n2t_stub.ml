(* Stub module to pre-compile dependencies - will be alongside user circuit *)
open! Hardcaml

module I = struct
  type 'a t = { a : 'a } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

(* Reference n2t_chips to ensure it's compiled *)
let create (_scope : Scope.t) (i : Signal.t I.t) : Signal.t O.t =
  let _ = N2t_chips.Nand.create in
  { out = i.a }
