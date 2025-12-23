(* Multiplexor: if (sel = 0) out = a, else out = b *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  (* N2T convention: sel=0 -> a, sel=1 -> b
     Hardcaml mux2: mux2 sel high low (high when sel=1, low when sel=0)
     So we pass: mux2 sel b a *)
  { out = mux2 i.sel i.b i.a }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux" create

