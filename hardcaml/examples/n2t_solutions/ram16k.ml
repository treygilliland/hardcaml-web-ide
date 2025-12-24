(* RAM16K: Memory of 16384 16-bit registers
   Uses 4 RAM4K chips with address[0..11] for internal, address[12..13] for select
   
   Implementation: DMux4Way -> 4 RAM4Ks -> Mux4Way16 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 14]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let addr_lo = select i.address ~high:11 ~low:0 in
  let addr_hi = select i.address ~high:13 ~low:12 in
  let la, lb, lc, ld = dmux4way_ scope i.load addr_hi in
  let ra = ram4k_ scope i.clock i.clear i.inp la addr_lo in
  let rb = ram4k_ scope i.clock i.clear i.inp lb addr_lo in
  let rc = ram4k_ scope i.clock i.clear i.inp lc addr_lo in
  let rd = ram4k_ scope i.clock i.clear i.inp ld addr_lo in
  { out = mux4way16_ scope ra rb rc rd addr_hi }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram16k" create

