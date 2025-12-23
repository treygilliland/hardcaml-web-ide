(* 4-way demultiplexor:
   [a, b, c, d] = [in, 0, 0, 0] if sel = 00
                  [0, in, 0, 0] if sel = 01
                  [0, 0, in, 0] if sel = 10
                  [0, 0, 0, in] if sel = 11 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let sel0 = bit i.sel ~pos:0 in
  let sel1 = bit i.sel ~pos:1 in
  { a = i.inp &: ~:sel0 &: ~:sel1
  ; b = i.inp &: sel0 &: ~:sel1
  ; c = i.inp &: ~:sel0 &: sel1
  ; d = i.inp &: sel0 &: sel1
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux4way" create
