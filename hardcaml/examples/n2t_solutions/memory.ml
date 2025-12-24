(* Memory: The complete address space of the Hack computer's memory
   Address space:
   - 0x0000-0x3FFF: RAM16K (16384 words)
   - 0x4000-0x5FFF: Screen (8192 words)
   - 0x6000: Keyboard (1 word)
   
   Implementation:
   - Use address[14] to select RAM vs I/O
   - Use address[13] within I/O to select Screen vs Keyboard
   - Use DMux to route load signals
   - Use Mux16 to select output *)

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
  let open N2t_chips in
  let addr14 = bit i.address ~pos:14 in
  let addr13 = bit i.address ~pos:13 in
  let addr_lo_13 = select i.address ~high:12 ~low:0 in
  let addr_lo_14 = select i.address ~high:13 ~low:0 in
  let loadram, loadio = dmux_ scope i.load addr14 in
  let loadscreen, _loadkbd = dmux_ scope loadio addr13 in
  let lowbits = or8way_ scope (select i.address ~high:7 ~low:0) in
  let midbits = or8way_ scope (uresize (select i.address ~high:12 ~low:8) ~width:8) in
  let has_low_bits = or_ scope lowbits midbits in
  let ramout = ram16k_ scope i.clock i.clear i.inp loadram addr_lo_14 in
  let screenout = screen_ scope i.clock i.clear i.inp loadscreen addr_lo_13 in
  let kbdout = keyboard_ scope i.clock i.clear i.key in
  let kbd_or_zero = mux16_ scope kbdout (zero 16) has_low_bits in
  let ioout = mux16_ scope screenout kbd_or_zero addr13 in
  { out = mux16_ scope ramout ioout addr14 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"memory" create

