(* RAM64: Memory of 64 16-bit registers
   Uses 8 RAM8 chips with address[0..2] for internal, address[3..5] for select
   
   Implementation: DMux8Way -> 8 RAM8s -> Mux8Way16 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 6]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let addr_lo = select i.address ~high:2 ~low:0 in
  let addr_hi = select i.address ~high:5 ~low:3 in
  let la, lb, lc, ld, le, lf, lg, lh = dmux8way_ scope i.load addr_hi in
  let ra = ram8_ scope i.clock i.clear i.inp la addr_lo in
  let rb = ram8_ scope i.clock i.clear i.inp lb addr_lo in
  let rc = ram8_ scope i.clock i.clear i.inp lc addr_lo in
  let rd = ram8_ scope i.clock i.clear i.inp ld addr_lo in
  let re = ram8_ scope i.clock i.clear i.inp le addr_lo in
  let rf = ram8_ scope i.clock i.clear i.inp lf addr_lo in
  let rg = ram8_ scope i.clock i.clear i.inp lg addr_lo in
  let rh = ram8_ scope i.clock i.clear i.inp lh addr_lo in
  { out = mux8way16_ scope ra rb rc rd re rf rg rh addr_hi }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram64" create
