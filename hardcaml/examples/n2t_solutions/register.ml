(* Register: 16-bit register with load enable
   if load(t) then out(t+1) = in(t)
   else out(t+1) = out(t)
   
   Implementation: 16 Bit chips sharing the same load wire *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let bits = List.init 16 ~f:(fun idx ->
    bit_ scope i.clock i.clear (bit i.inp ~pos:idx) i.load)
  in
  { out = concat_lsb bits }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"register" create

