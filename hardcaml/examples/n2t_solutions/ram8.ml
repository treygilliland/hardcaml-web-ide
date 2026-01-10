(* RAM8: Memory of 8 16-bit registers
   If load is asserted, the value of the register selected by
   address is set to in; Otherwise, the value does not change.
   The value of the selected register is emitted by out.
   
   Implementation:
   - DMux8Way to distribute load to selected register
   - 8 Registers
   - Mux8Way16 to select output *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let la, lb, lc, ld, le, lf, lg, lh = dmux8way_ scope i.load i.address in
  let ra = register_ scope i.clock i.clear i.inp la in
  let rb = register_ scope i.clock i.clear i.inp lb in
  let rc = register_ scope i.clock i.clear i.inp lc in
  let rd = register_ scope i.clock i.clear i.inp ld in
  let re = register_ scope i.clock i.clear i.inp le in
  let rf = register_ scope i.clock i.clear i.inp lf in
  let rg = register_ scope i.clock i.clear i.inp lg in
  let rh = register_ scope i.clock i.clear i.inp lh in
  { out = mux8way16_ scope ra rb rc rd re rf rg rh i.address }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram8" create
