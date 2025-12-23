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
   - ng: if out < 0 then ng = 1, else ng = 0
   
   Implement using Mux16, Not16, Add16, And16, Or8Way, and basic gates. *)

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips *)
  { out = zero 16; zr = gnd; ng = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"alu" create

