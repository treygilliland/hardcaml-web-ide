(* NAND gate - the fundamental building block of the Hack chipset *)

open! Core
open! Hardcaml
open Signal

let nand a b = ~:(a &: b)

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t = { out = nand i.a i.b }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"nand" create
