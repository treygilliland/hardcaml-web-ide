(* ALU (Arithmetic Logic Unit): Computes various functions of x and y
   
   Hierarchical implementation using Mux16, Not16, Add16, And16, Or8Way *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { x : 'a [@bits 16]
    ; y : 'a [@bits 16]
    ; zx : 'a
    ; nx : 'a
    ; zy : 'a
    ; ny : 'a
    ; f : 'a
    ; no : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { out : 'a [@bits 16]
    ; zr : 'a
    ; ng : 'a
    }
  [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  (* Mux16(a=x, b=false, sel=zx): sel=0->a, sel=1->b *)
  let x1 = mux16_ scope i.x (zero 16) i.zx in
  (* Mux16(a=x1, b=notx, sel=nx) *)
  let not_x1 = not16_ scope x1 in
  let x2 = mux16_ scope x1 not_x1 i.nx in
  (* Mux16(a=y, b=false, sel=zy) *)
  let y1 = mux16_ scope i.y (zero 16) i.zy in
  (* Mux16(a=y1, b=noty, sel=ny) *)
  let not_y1 = not16_ scope y1 in
  let y2 = mux16_ scope y1 not_y1 i.ny in
  (* f=0 -> and, f=1 -> add *)
  let f_add = add16_ scope x2 y2 in
  let f_and = and16_ scope x2 y2 in
  let out1 = mux16_ scope f_and f_add i.f in
  (* no=0 -> out1, no=1 -> not_out1 *)
  let not_out1 = not16_ scope out1 in
  let out2 = mux16_ scope out1 not_out1 i.no in
  (* zr: or all bits and negate *)
  let or_lo = or8way_ scope (select out2 ~high:7 ~low:0) in
  let or_hi = or8way_ scope (select out2 ~high:15 ~low:8) in
  let zr = not_ scope (or_ scope or_lo or_hi) in
  (* ng is just the MSB *)
  let ng = msb out2 in
  { out = out2; zr; ng }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"alu" create
