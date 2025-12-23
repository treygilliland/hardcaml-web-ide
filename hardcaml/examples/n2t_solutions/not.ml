(* Not gate: if (in) out = 0, else out = 1
   
   Implementation using only N2t_chips.Nand.nand *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  { out = N2t_chips.Nand.nand i.a i.a }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"not" create

