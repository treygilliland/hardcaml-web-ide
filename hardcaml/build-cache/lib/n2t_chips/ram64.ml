(* RAM64: Memory of 64 16-bit registers
   Uses 8 RAM8 chips, addressed by upper 3 bits of 6-bit address *)

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

let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let addr_lo = select i.address ~high:2 ~low:0 in
  let addr_hi = select i.address ~high:5 ~low:3 in
  let load_enables = binary_to_onehot addr_hi in
  let ram8s = 
    List.init 8 ~f:(fun idx ->
      let enable = i.load &: bit load_enables ~pos:idx in
      let ram_load_enables = binary_to_onehot addr_lo in
      List.init 8 ~f:(fun reg_idx ->
        let reg_enable = enable &: bit ram_load_enables ~pos:reg_idx in
        reg spec ~enable:reg_enable i.inp)
      |> fun regs -> mux addr_lo regs)
  in
  { out = mux addr_hi ram8s }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram64" create

