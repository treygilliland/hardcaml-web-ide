(* Computer: The Hack computer, consisting of CPU, ROM and RAM
   When reset = 0, the program stored in the ROM executes.
   When reset = 1, the program's execution restarts. *)

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
  let pc = wire 15 in
  let instruction = Rom32k.create scope { Rom32k.I.clock = i.clock; address = pc } in
  let mem_out = wire 16 in
  let cpu = Cpu.create scope { Cpu.I.clock = i.clock; clear = i.clear; inM = mem_out; instruction = instruction.out; reset = i.reset } in
  pc <-- cpu.pc;
  let memory = Memory.create scope { Memory.I.clock = i.clock; clear = i.clear; inp = cpu.outM; load = cpu.writeM; address = cpu.addressM; key = i.key } in
  mem_out <-- memory.out;
  { pc = cpu.pc; addressM = cpu.addressM; outM = cpu.outM; writeM = cpu.writeM }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"computer" create
