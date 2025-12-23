(* Not gate: if (in) out = 0, else out = 1
   
   Implement using only N2t_chips.Nand.nand
   Hint: What happens when you NAND a signal with itself? *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.Nand.nand *)
  { out = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"not" create

