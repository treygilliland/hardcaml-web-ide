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
