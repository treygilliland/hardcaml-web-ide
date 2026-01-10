(* 4-way demultiplexor:
   [a, b, c, d] = [in, 0, 0, 0] if sel = 00
                  [0, in, 0, 0] if sel = 01
                  [0, 0, in, 0] if sel = 10
                  [0, 0, 0, in] if sel = 11
   
   Hint: Use DMux to split by sel[1] into (ab, cd), then DMux each by sel[0]. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement DMux4Way *)
  { a = gnd; b = gnd; c = gnd; d = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux4way" create
