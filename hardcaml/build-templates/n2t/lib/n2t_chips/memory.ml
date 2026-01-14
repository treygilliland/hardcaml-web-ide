(* Memory: The complete address space of the Hack computer's memory
   Address space:
   - 0x0000-0x3FFF: RAM16K (16384 words)
   - 0x4000-0x5FFF: Screen (8192 words)
   - 0x6000: Keyboard (1 word)
   
   Access to address > 0x6000 is invalid *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16] [@rtlname "in"]
    ; load : 'a
    ; address : 'a [@bits 15]
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let addr14 = bit i.address ~pos:14 in
  let addr13 = bit i.address ~pos:13 in
  let addr_lo_13 = select i.address ~high:12 ~low:0 in
  let addr_lo_14 = select i.address ~high:13 ~low:0 in
  let dmux1 = Dmux.create scope { Dmux.I.inp = i.load; sel = addr14 } in
  let loadram = dmux1.Dmux.O.a in
  let loadio = dmux1.Dmux.O.b in
  let dmux2 = Dmux.create scope { Dmux.I.inp = loadio; sel = addr13 } in
  let loadscreen = dmux2.Dmux.O.a in
  let lowbits = (Or8way.create scope { Or8way.I.a = select i.address ~high:7 ~low:0 }).out in
  let midbits = (Or8way.create scope { Or8way.I.a = uresize (select i.address ~high:12 ~low:8) ~width:8 }).out in
  let has_low_bits = (Or.create scope { Or.I.a = lowbits; b = midbits }).out in
  let ramout = Ram16k.create scope { Ram16k.I.clock = i.clock; clear = i.clear; inp = i.inp; load = loadram; address = addr_lo_14 } in
  let screenout = Screen.create scope { Screen.I.clock = i.clock; clear = i.clear; inp = i.inp; load = loadscreen; address = addr_lo_13 } in
  let kbdout = Keyboard.create scope { Keyboard.I.clock = i.clock; clear = i.clear; key = i.key } in
  let kbd_or_zero = mux2 has_low_bits (zero 16) kbdout.out in
  let ioout = mux2 addr13 kbd_or_zero screenout.out in
  { out = mux2 addr14 ioout ramout.out }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"memory" create
