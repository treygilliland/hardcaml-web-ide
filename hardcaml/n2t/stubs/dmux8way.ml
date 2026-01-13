(* 8-way demultiplexor:
   [a, b, c, d, e, f, g, h] = [in, 0, 0, 0, 0, 0, 0, 0] if sel = 000
                              [0, in, 0, 0, 0, 0, 0, 0] if sel = 001
                              ... etc
   
   Hint: Use DMux to split by sel[2] into (abcd, efgh),
   then DMux4Way each using sel[0..1]. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    ; e : 'a
    ; f : 'a
    ; g : 'a
    ; h : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement DMux8Way *)
  { a = gnd; b = gnd; c = gnd; d = gnd; e = gnd; f = gnd; g = gnd; h = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux8way" create
