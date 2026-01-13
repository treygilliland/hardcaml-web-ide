(* 4-way demultiplexor:
   [a, b, c, d] = [in, 0, 0, 0] if sel = 00
                  [0, in, 0, 0] if sel = 01
                  [0, 0, in, 0] if sel = 10
                  [0, 0, 0, in] if sel = 11
   
   Hierarchical implementation: DMux by sel[1], then DMux each result by sel[0]. *)

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

let create scope (i : _ I.t) : _ O.t =
  let sel0 = bit i.sel ~pos:0 in
  let sel1 = bit i.sel ~pos:1 in
  let ab, cd = N2t_chips.dmux_ scope i.inp sel1 in
  let a, b = N2t_chips.dmux_ scope ab sel0 in
  let c, d = N2t_chips.dmux_ scope cd sel0 in
  { a; b; c; d }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux4way" create
