(* Full Adder: Computes the sum of three bits
   sum = LSB of a + b + c
   carry = MSB of a + b + c *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { sum : 'a
    ; carry : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let ab_sum = i.a ^: i.b in
  let ab_carry = i.a &: i.b in
  let sum = ab_sum ^: i.c in
  let carry = ab_carry |: (ab_sum &: i.c) in
  { sum; carry }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"fulladder" create

