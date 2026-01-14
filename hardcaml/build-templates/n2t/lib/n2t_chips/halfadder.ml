(* Half Adder: Computes the sum of two bits
   sum = LSB of a + b
   carry = MSB of a + b *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
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
  { sum = i.a ^: i.b
  ; carry = i.a &: i.b
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"halfadder" create
