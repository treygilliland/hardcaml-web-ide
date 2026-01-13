(* 8-way Or gate: out = in[0] Or in[1] Or ... Or in[7]
   
   Implement by chaining Or gates together, or use a tree reduction.
   Hint: You can use N2t_chips.or_ to chain Or gates. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { a : 'a [@bits 8] } [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement Or8Way *)
  { out = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"or8way" create
