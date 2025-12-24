(* RAM4K: Memory of 4096 16-bit registers
   Uses 8 RAM512 chips with address[0..8] for internal, address[9..11] for select
   
   Implementation: DMux8Way -> 8 RAM512s -> Mux8Way16 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 12]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let addr_lo = select i.address ~high:8 ~low:0 in
  let addr_hi = select i.address ~high:11 ~low:9 in
  let la, lb, lc, ld, le, lf, lg, lh = dmux8way_ scope i.load addr_hi in
  let ra = ram512_ scope i.clock i.clear i.inp la addr_lo in
  let rb = ram512_ scope i.clock i.clear i.inp lb addr_lo in
  let rc = ram512_ scope i.clock i.clear i.inp lc addr_lo in
  let rd = ram512_ scope i.clock i.clear i.inp ld addr_lo in
  let re = ram512_ scope i.clock i.clear i.inp le addr_lo in
  let rf = ram512_ scope i.clock i.clear i.inp lf addr_lo in
  let rg = ram512_ scope i.clock i.clear i.inp lg addr_lo in
  let rh = ram512_ scope i.clock i.clear i.inp lh addr_lo in
  { out = mux8way16_ scope ra rb rc rd re rf rg rh addr_hi }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram4k" create

