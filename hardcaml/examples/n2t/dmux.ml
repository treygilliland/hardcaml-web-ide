(* Demultiplexor:
   [a, b] = [in, 0] if sel = 0
            [0, in] if sel = 1
   
   Implement using only N2t_chips.Nand.nand
   Hint: a = in AND NOT(sel), b = in AND sel *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.Nand.nand *)
  { a = gnd; b = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux" create

