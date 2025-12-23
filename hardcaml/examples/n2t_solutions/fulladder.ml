(* Full Adder: Computes the sum of three bits
   
   Hierarchical implementation using two HalfAdders and an Or gate *)

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

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let sum1, carry1 = halfadder_ scope i.a i.b in
  let sum2, carry2 = halfadder_ scope sum1 i.c in
  { sum = sum2
  ; carry = or_ scope carry1 carry2
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"fulladder" create

