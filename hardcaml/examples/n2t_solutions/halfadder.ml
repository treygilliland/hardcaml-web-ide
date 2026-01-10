(* Half Adder: Computes the sum of two bits
   
   Hierarchical implementation using XOR and AND gates *)

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

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  { sum = xor_ scope i.a i.b
  ; carry = and_ scope i.a i.b
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"halfadder" create
