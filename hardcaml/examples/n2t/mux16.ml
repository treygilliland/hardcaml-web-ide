(* 16-bit multiplexor: for i = 0..15: if (sel = 0) out[i] = a[i], else out[i] = b[i]
   
   Implement by applying Mux to each pair of bits with the same selector.
   Hint: Use N2t_chips.mux_ or build it up from 16 individual Mux gates. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement Mux16 *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux16" create

