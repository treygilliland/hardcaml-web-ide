(* Computer: The Hack computer, consisting of CPU, ROM and RAM
   When reset = 0, the program stored in the ROM executes.
   When reset = 1, the program's execution restarts.
   
   Implementation:
   - ROM32K holds the program, addressed by PC
   - CPU fetches instruction from ROM, executes it
   - Memory provides RAM, Screen, and Keyboard access *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; reset : 'a
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc : 'a [@bits 15]
    ; addressM : 'a [@bits 15]
    ; outM : 'a [@bits 16]
    ; writeM : 'a
    }
  [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let pc_wire = wire 15 in
  let instruction = rom32k_ scope i.clock pc_wire in
  let mem_out = wire 16 in
  let outM, writeM, addressM, pc = cpu_ scope i.clock i.clear mem_out instruction i.reset in
  pc_wire <-- pc;
  let mem = memory_ scope i.clock i.clear outM writeM addressM i.key in
  mem_out <-- mem;
  { pc; addressM; outM; writeM }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"computer" create
