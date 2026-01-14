(* Hello Nand Gate: Your first Hardcaml circuit!
   
   This example shows:
   - The NAND Gate -- all other logic gates can be built from it!
   - Basic Hardcaml structure: I (input), O (output), create function
   - Hardcaml operators: ~:(a &: b) which means NOT (A AND B)
 *)

open! Core
open! Hardcaml
open! Signal

(* Define a module for input interface *)
module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

(* Define a module for output interface *)
module O = struct
  type 'a t = { out : 'a }
  [@@deriving hardcaml]
end

(* Circuit creation function *)
let create _scope (i : _ I.t) : _ O.t =
  (* NAND gate: NOT (A AND B) *)
  (* In Hardcaml: ~: is NOT, &: is AND *)
  { out = ~:(i.a &: i.b) }

(* Hierarchical wrapper - needed for Hardcaml *)
let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"nand" create
