(* Xor gate: if ((a and Not(b)) or (Not(a) and b)) out = 1, else out = 0
   
   Implement using only N2t_chips.Nand.nand
   Hint: XOR = (a NAND (a NAND b)) NAND (b NAND (a NAND b)) *)

open! Core
open! Hardcaml
open! Signal

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.Nand.nand *)
  { out = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"xor" create

