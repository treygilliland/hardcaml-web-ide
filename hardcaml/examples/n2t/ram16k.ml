(* RAM16K: Memory of 16384 16-bit registers
   Uses 4 RAM4K chips with address[0..11] for internal, address[12..13] for select
   
   Implement using DMux4Way, 4 RAM4Ks, and Mux4Way16 *)

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

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.ram4k_, dmux4way_, mux4way16_ *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"ram16k" create

