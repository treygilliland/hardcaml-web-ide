(* RAM4K: Memory of 4096 16-bit registers
   Uses 8 RAM512 chips with address[0..8] for internal, address[9..11] for select
   
   Implement using DMux8Way, 8 RAM512s, and Mux8Way16 *)

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.ram512_, dmux8way_, mux8way16_ *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram4k" create
