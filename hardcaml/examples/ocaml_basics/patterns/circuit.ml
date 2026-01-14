(* Hello Patterns: Demonstrates pattern matching and record destructuring
   
   This example shows:
   - pattern matching on records
   - record destructuring in function parameters
   - using destructured values
   - multiplexer circuit *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; sel : 'a  (* Select: 0 = a, 1 = b *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a }
  [@@deriving hardcaml]
end

(* Method 1: Pattern matching in function parameter *)
let create _scope ({ a; b; sel } : _ I.t) : _ O.t =
  (* a, b, and sel are now available directly *)
  (* N2T convention: sel=0 -> a, sel=1 -> b
     Hardcaml mux2: mux2 sel high low (high when sel=1, low when sel=0)
     So we pass: mux2 sel b a *)
  { out = mux2 sel b a }

(* Alternative method (commented out): Access via record *)
(*
let create _scope (i : _ I.t) : _ O.t =
  let a = i.a in
  let b = i.b in
  let sel = i.sel in
  { out = mux2 sel b a }
*)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"patterns" create
