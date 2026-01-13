(* 16-bit Incrementer: out = in + 1
   
   Implement using Add16. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { inp : 'a [@bits 16] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.Add16 *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"inc16" create
