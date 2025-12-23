(* Multiplexor: if (sel = 0) out = a, else out = b
   
   Implement using only N2t_chips.Nand.nand
   Hint: MUX = (a AND NOT(sel)) OR (b AND sel) *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; sel : 'a
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
  Scoped.hierarchical ~scope ~name:"mux" create

