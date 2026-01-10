(* DFF: D Flip-Flop - stores a single bit
   out(t) = in(t-1)
   
   The DFF is a primitive in Hardcaml. Use reg with a Reg_spec. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using Reg_spec and reg *)
  { out = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dff" create
