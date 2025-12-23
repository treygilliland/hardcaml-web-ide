(* Demultiplexor:
   [a, b] = [in, 0] if sel = 0
            [0, in] if sel = 1
   
   Implement using only Nand gates from the N2t library.
   Hint: a = in AND NOT(sel), b = in AND sel *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let open N2t in
  let not_sel = nand_ i.sel i.sel in
  let a_nand = nand_ i.inp not_sel in
  let b_nand = nand_ i.inp i.sel in
  { a = nand_ a_nand a_nand
  ; b = nand_ b_nand b_nand
  }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux" create
;;

