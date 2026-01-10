(* DRegister: 16-bit D register for the Hack CPU
   Stores the data value for ALU operations *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16] [@rtlname "in"]
    ; load : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  { out = reg spec ~enable:i.load i.inp }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dregister" create
