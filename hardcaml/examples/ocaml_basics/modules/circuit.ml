(* Hello Modules: Demonstrates OCaml modules, struct, sig, and open!
   
   This example shows:
   - module definitions with struct
   - opening modules with open!
   - module signatures
   - local modules
   - Hardcaml module pattern *)

(* Open modules - the ! forces open even with name conflicts *)
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
  (* Simple AND gate using Hardcaml operator *)
  { out = i.a &: i.b }

(* Hierarchical wrapper - demonstrates local module *)
let hierarchical scope =
  (* Create a local module Scoped *)
  let module Scoped = Hierarchy.In_scope (I) (O) in
  (* Use the module's hierarchical function *)
  Scoped.hierarchical ~scope ~name:"modules" create
