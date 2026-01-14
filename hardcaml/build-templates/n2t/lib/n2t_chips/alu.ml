(* ALU (Arithmetic Logic Unit): Computes various functions of x and y
   
   Control bits:
   - zx: if 1 then x = 0
   - nx: if 1 then x = !x
   - zy: if 1 then y = 0
   - ny: if 1 then y = !y
   - f:  if 1 then out = x + y, else out = x & y
   - no: if 1 then out = !out
   
   Output flags:
   - zr: if out = 0 then zr = 1, else zr = 0
   - ng: if out < 0 then ng = 1, else ng = 0 *)

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

let create _scope (i : _ I.t) : _ O.t =
  let x1 = mux2 i.zx (zero 16) i.x in
  let x2 = mux2 i.nx (~:x1) x1 in
  let y1 = mux2 i.zy (zero 16) i.y in
  let y2 = mux2 i.ny (~:y1) y1 in
  let f_add = x2 +: y2 in
  let f_and = x2 &: y2 in
  let out1 = mux2 i.f f_add f_and in
  let out2 = mux2 i.no (~:out1) out1 in
  let zr = out2 ==: (zero 16) in
  let ng = msb out2 in
  { out = out2; zr; ng }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"alu" create
