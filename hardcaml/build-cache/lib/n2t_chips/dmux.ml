(* Demultiplexor:
   [a, b] = [in, 0] if sel = 0
            [0, in] if sel = 1 *)

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
  { a = i.inp &: ~:(i.sel)
  ; b = i.inp &: i.sel
  }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"dmux" create

