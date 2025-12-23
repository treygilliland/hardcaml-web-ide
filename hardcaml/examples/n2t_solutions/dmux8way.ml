(* 8-way demultiplexor:
   [a, b, c, d, e, f, g, h] = [in, 0, 0, 0, 0, 0, 0, 0] if sel = 000
                              [0, in, 0, 0, 0, 0, 0, 0] if sel = 001
                              ... etc
   
   Hierarchical implementation: DMux by sel[2], then DMux4Way each result. *)

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

let create scope (i : _ I.t) : _ O.t =
  let sel01 = select i.sel ~high:1 ~low:0 in
  let sel2 = bit i.sel ~pos:2 in
  let abcd, efgh = N2t_chips.dmux_ scope i.inp sel2 in
  let a, b, c, d = N2t_chips.dmux4way_ scope abcd sel01 in
  let e, f, g, h = N2t_chips.dmux4way_ scope efgh sel01 in
  { a; b; c; d; e; f; g; h }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux8way" create
