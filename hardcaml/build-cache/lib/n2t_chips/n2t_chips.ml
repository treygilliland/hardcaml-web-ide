(* Nand2Tetris Chip Library for Hardcaml
   
   Reference implementations of the Hack chipset, importable as N2t_chips.ChipName *)

module Nand = Nand
module Not = Not
module And = And
module Or = Or
module Xor = Xor
module Mux = Mux
module Dmux = Dmux

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

