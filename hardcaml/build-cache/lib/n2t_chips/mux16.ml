(* 16-bit multiplexor: for i = 0..15: if (sel = 0) out[i] = a[i], else out[i] = b[i] *)

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

let create _scope (i : _ I.t) : _ O.t =
  (* N2T convention: sel=0 -> a, sel=1 -> b
     Hardcaml mux2: mux2 sel high low (high when sel=1, low when sel=0) *)
  { out = mux2 i.sel i.b i.a }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux16" create

