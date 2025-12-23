(* Multiplexor: if (sel = 0) out = a, else out = b
   
   Implement using only Nand gates from the N2t library.
   Hint: MUX = (a AND NOT(sel)) OR (b AND sel) *)

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
  let open N2t in
  let not_sel = nand_ i.sel i.sel in
  let a_and_notsel = nand_ (nand_ i.a not_sel) (nand_ i.a not_sel) in
  let b_and_sel = nand_ (nand_ i.b i.sel) (nand_ i.b i.sel) in
  let not_a_and_notsel = nand_ a_and_notsel a_and_notsel in
  let not_b_and_sel = nand_ b_and_sel b_and_sel in
  { out = nand_ not_a_and_notsel not_b_and_sel }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux" create
;;

