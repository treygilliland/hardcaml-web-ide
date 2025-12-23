(* 8-way demultiplexor:
   [a, b, c, d, e, f, g, h] = [in, 0, 0, 0, 0, 0, 0, 0] if sel = 000
                              [0, in, 0, 0, 0, 0, 0, 0] if sel = 001
                              ... etc *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { inp : 'a
    ; sel : 'a [@bits 3]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    ; c : 'a
    ; d : 'a
    ; e : 'a
    ; f : 'a
    ; g : 'a
    ; h : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let sel0 = bit i.sel ~pos:0 in
  let sel1 = bit i.sel ~pos:1 in
  let sel2 = bit i.sel ~pos:2 in
  { a = i.inp &: ~:sel0 &: ~:sel1 &: ~:sel2
  ; b = i.inp &: sel0 &: ~:sel1 &: ~:sel2
  ; c = i.inp &: ~:sel0 &: sel1 &: ~:sel2
  ; d = i.inp &: sel0 &: sel1 &: ~:sel2
  ; e = i.inp &: ~:sel0 &: ~:sel1 &: sel2
  ; f = i.inp &: sel0 &: ~:sel1 &: sel2
  ; g = i.inp &: ~:sel0 &: sel1 &: sel2
  ; h = i.inp &: sel0 &: sel1 &: sel2
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux8way" create
