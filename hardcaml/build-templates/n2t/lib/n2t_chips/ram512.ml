(* RAM512: Memory of 512 16-bit registers
   Uses 8 RAM64 chips, addressed by upper 3 bits of 9-bit address *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; address : 'a [@bits 9]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let addr_lo = select i.address ~high:5 ~low:0 in
  let addr_hi = select i.address ~high:8 ~low:6 in
  let load_enables = binary_to_onehot addr_hi in
  let ram64s = 
    List.init 8 ~f:(fun idx ->
      let enable = i.load &: bit load_enables ~pos:idx in
      Ram64.create scope { Ram64.I.clock = i.clock; clear = i.clear; inp = i.inp; load = enable; address = addr_lo })
  in
  { out = mux addr_hi (List.map ram64s ~f:(fun r -> r.out)) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram512" create
