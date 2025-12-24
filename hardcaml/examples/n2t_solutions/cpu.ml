(* CPU: The Hack Central Processing Unit
   
   Instruction format:
   A-instruction (MSB=0): @value - loads value into A register
   C-instruction (MSB=1): 1 1 1 a c1 c2 c3 c4 c5 c6 d1 d2 d3 j1 j2 j3
     - a (bit 12): comp uses M if 1, A if 0
     - c1-c6 (bits 11-6): ALU control (zx, nx, zy, ny, f, no)
     - d1-d3 (bits 5-3): destination (A, D, M)
     - j1-j3 (bits 2-0): jump condition (lt, eq, gt)
   
   Implementation:
   - A register: loaded from instruction (A-instr) or ALU output (C-instr with d1)
   - D register: loaded from ALU output (C-instr with d2)
   - ALU: computes based on c1-c6, uses D and either A or M (based on 'a' bit)
   - PC: increments, loads from A on jump, resets to 0 on reset *)

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

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let is_c_instr = bit i.instruction ~pos:15 in
  let is_a_instr = ~:is_c_instr in
  let a_bit = bit i.instruction ~pos:12 in
  let zx = bit i.instruction ~pos:11 in
  let nx = bit i.instruction ~pos:10 in
  let zy = bit i.instruction ~pos:9 in
  let ny = bit i.instruction ~pos:8 in
  let f = bit i.instruction ~pos:7 in
  let no = bit i.instruction ~pos:6 in
  let d1 = bit i.instruction ~pos:5 in
  let d2 = bit i.instruction ~pos:4 in
  let d3 = bit i.instruction ~pos:3 in
  let j1 = bit i.instruction ~pos:2 in
  let j2 = bit i.instruction ~pos:1 in
  let j3 = bit i.instruction ~pos:0 in
  let a_reg = wire 16 in
  let d_reg = wire 16 in
  let a_or_m = mux16_ scope a_reg i.inM (is_c_instr &: a_bit) in
  let alu_out, zr, ng = alu_ scope d_reg a_or_m zx nx zy ny f no in
  let load_a = or_ scope is_a_instr (and_ scope is_c_instr d1) in
  let a_in = mux16_ scope alu_out i.instruction is_a_instr in
  a_reg <-- reg spec ~enable:load_a a_in;
  let load_d = and_ scope is_c_instr d2 in
  d_reg <-- reg spec ~enable:load_d alu_out;
  let pos = and_ scope (~:ng) (~:zr) in
  let jlt = and_ scope j1 ng in
  let jeq = and_ scope j2 zr in
  let jgt = and_ scope j3 pos in
  let do_jump = or_ scope jlt (or_ scope jeq jgt) in
  let load_pc = and_ scope is_c_instr do_jump in
  let pc_out = pc_ scope i.clock i.clear a_reg load_pc vdd i.reset in
  { outM = alu_out
  ; writeM = and_ scope is_c_instr d3
  ; addressM = select a_reg ~high:14 ~low:0
  ; pc = select pc_out ~high:14 ~low:0
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"cpu" create

