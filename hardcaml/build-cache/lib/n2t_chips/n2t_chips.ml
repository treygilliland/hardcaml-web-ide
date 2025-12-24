(* Nand2Tetris Chip Library for Hardcaml
   
   Reference implementations of the Hack chipset, importable as N2t_chips.ChipName *)

module Nand = Nand
module Not = Not
module And = And
module Or = Or
module Xor = Xor
module Mux = Mux
module Dmux = Dmux
module Not16 = Not16
module And16 = And16
module Or16 = Or16
module Mux16 = Mux16
module Or8way = Or8way
module Mux4way16 = Mux4way16
module Mux8way16 = Mux8way16
module Dmux4way = Dmux4way
module Dmux8way = Dmux8way
module Halfadder = Halfadder
module Fulladder = Fulladder
module Add16 = Add16
module Inc16 = Inc16
module Alu = Alu
module Dff = Dff
module Bit = Bit
module Register = Register
module Ram8 = Ram8
module Pc = Pc
module Ram64 = Ram64
module Ram512 = Ram512
module Ram4k = Ram4k
module Ram16k = Ram16k

(* Convenience functions for concise chip instantiation.
   Usage: let open N2t_chips in not_ scope sel *)

let nand_ scope a b = (Nand.create scope { Nand.I.a; b }).out
let not_ scope a = (Not.create scope { Not.I.a }).out
let and_ scope a b = (And.create scope { And.I.a; b }).out
let or_ scope a b = (Or.create scope { Or.I.a; b }).out
let xor_ scope a b = (Xor.create scope { Xor.I.a; b }).out
let mux_ scope a b sel = (Mux.create scope { Mux.I.a; b; sel }).out
let dmux_ scope inp sel =
  let o = Dmux.create scope { Dmux.I.inp; sel } in
  o.a, o.b

let not16_ scope a = (Not16.create scope { Not16.I.a }).out
let and16_ scope a b = (And16.create scope { And16.I.a; b }).out
let or16_ scope a b = (Or16.create scope { Or16.I.a; b }).out
let mux16_ scope a b sel = (Mux16.create scope { Mux16.I.a; b; sel }).out
let or8way_ scope a = (Or8way.create scope { Or8way.I.a }).out
let mux4way16_ scope a b c d sel = (Mux4way16.create scope { Mux4way16.I.a; b; c; d; sel }).out
let mux8way16_ scope a b c d e f g h sel = 
  (Mux8way16.create scope { Mux8way16.I.a; b; c; d; e; f; g; h; sel }).out
let dmux4way_ scope inp sel =
  let o = Dmux4way.create scope { Dmux4way.I.inp; sel } in
  o.a, o.b, o.c, o.d
let dmux8way_ scope inp sel =
  let o = Dmux8way.create scope { Dmux8way.I.inp; sel } in
  o.a, o.b, o.c, o.d, o.e, o.f, o.g, o.h

let halfadder_ scope a b =
  let o = Halfadder.create scope { Halfadder.I.a; b } in
  o.sum, o.carry
let fulladder_ scope a b c =
  let o = Fulladder.create scope { Fulladder.I.a; b; c } in
  o.sum, o.carry
let add16_ scope a b = (Add16.create scope { Add16.I.a; b }).out
let inc16_ scope inp = (Inc16.create scope { Inc16.I.inp }).out
let alu_ scope x y zx nx zy ny f no =
  let o = Alu.create scope { Alu.I.x; y; zx; nx; zy; ny; f; no } in
  o.out, o.zr, o.ng

let dff_ scope clock clear inp = 
  (Dff.create scope { Dff.I.clock; clear; inp }).out
let bit_ scope clock clear inp load = 
  (Bit.create scope { Bit.I.clock; clear; inp; load }).out
let register_ scope clock clear inp load = 
  (Register.create scope { Register.I.clock; clear; inp; load }).out
let ram8_ scope clock clear inp load address = 
  (Ram8.create scope { Ram8.I.clock; clear; inp; load; address }).out
let pc_ scope clock clear inp load inc reset = 
  (Pc.create scope { Pc.I.clock; clear; inp; load; inc; reset }).out
let ram64_ scope clock clear inp load address = 
  (Ram64.create scope { Ram64.I.clock; clear; inp; load; address }).out
let ram512_ scope clock clear inp load address = 
  (Ram512.create scope { Ram512.I.clock; clear; inp; load; address }).out
let ram4k_ scope clock clear inp load address = 
  (Ram4k.create scope { Ram4k.I.clock; clear; inp; load; address }).out
let ram16k_ scope clock clear inp load address = 
  (Ram16k.create scope { Ram16k.I.clock; clear; inp; load; address }).out
