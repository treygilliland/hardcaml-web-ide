(* CPU: The Hack Central Processing Unit
   
   Instruction format:
   A-instruction (MSB=0): @value - loads value into A register
   C-instruction (MSB=1): 1 1 1 a c1 c2 c3 c4 c5 c6 d1 d2 d3 j1 j2 j3
     - a (bit 12): comp uses M if 1, A if 0
     - c1-c6 (bits 11-6): ALU control (zx, nx, zy, ny, f, no)
     - d1-d3 (bits 5-3): destination (A, D, M)
     - j1-j3 (bits 2-0): jump condition (lt, eq, gt)
   
   Implement using ALU, PC, registers, and mux chips *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inM : 'a [@bits 16]
    ; instruction : 'a [@bits 16]
    ; reset : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { outM : 'a [@bits 16]
    ; writeM : 'a
    ; addressM : 'a [@bits 15]
    ; pc : 'a [@bits 15]
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement the Hack CPU *)
  { outM = zero 16; writeM = gnd; addressM = zero 15; pc = zero 15 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"cpu" create

