(* RAM8: Memory of 8 16-bit registers
   If load is asserted, the value of the register selected by
   address is set to in; Otherwise, the value does not change.
   The value of the selected register is emitted by out. *)

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

let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let load_enables = binary_to_onehot i.address in
  let registers = 
    List.init 8 ~f:(fun idx ->
      let enable = i.load &: bit load_enables ~pos:idx in
      reg spec ~enable i.inp)
  in
  { out = mux i.address registers }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram8" create

