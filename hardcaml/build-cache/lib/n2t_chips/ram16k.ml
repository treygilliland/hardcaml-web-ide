(* RAM16K: Memory of 16384 16-bit registers
   Uses 4 RAM4K chips, addressed by upper 2 bits of 14-bit address *)

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
  let addr_lo = select i.address ~high:11 ~low:0 in
  let addr_hi = select i.address ~high:13 ~low:12 in
  let load_enables = binary_to_onehot addr_hi in
  let ram4ks = 
    List.init 4 ~f:(fun idx ->
      let enable = i.load &: bit load_enables ~pos:idx in
      Ram4k.create scope { Ram4k.I.clock = i.clock; clear = i.clear; inp = i.inp; load = enable; address = addr_lo })
  in
  { out = mux addr_hi (List.map ram4ks ~f:(fun r -> r.out)) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram16k" create

