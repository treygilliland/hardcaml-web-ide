(* RAM8: Memory of 8 16-bit registers
   If load is asserted, the value of the register selected by
   address is set to in; Otherwise, the value does not change.
   The value of the selected register is emitted by out.
   
   Implement using 8 Registers, DMux8Way for load, Mux8Way16 for out *)

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.register_, dmux8way_, mux8way16_ *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram8" create

