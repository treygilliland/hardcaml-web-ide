(* Hello Operators: Demonstrates Hardcaml infix operators
   
   This example shows:
   - &: (bitwise AND)
   - |: (bitwise OR)
   - ^: (bitwise XOR)
   - ~: (bitwise NOT)
   - +: (addition)
   - ==: (equality)
   - Combining operators
   *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 4]
    ; b : 'a [@bits 4]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { and_out : 'a [@bits 4]   (* a AND b *)
    ; or_out : 'a [@bits 4]    (* a OR b *)
    ; xor_out : 'a [@bits 4]   (* a XOR b *)
    ; not_a : 'a [@bits 4]     (* NOT a *)
    ; sum : 'a [@bits 4]        (* a + b *)
    ; equal : 'a                (* a == b *)
    }
  [@@deriving hardcaml]
end

let create _scope ({ a; b } : _ I.t) : _ O.t =
  (* Bitwise AND: &: *)
  let and_out = a &: b in
  
  (* Bitwise OR: |: *)
  let or_out = a |: b in
  
  (* Bitwise XOR: ^: *)
  let xor_out = a ^: b in
  
  (* Bitwise NOT: ~: *)
  let not_a = ~:a in
  
  (* Addition: +: *)
  let sum = a +: b in
  
  (* Equality comparison: ==: *)
  let equal = a ==: b in
  
  { and_out
  ; or_out
  ; xor_out
  ; not_a
  ; sum
  ; equal
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"hello_operators" create
