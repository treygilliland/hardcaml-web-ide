(* Nand2Tetris Hack Chipset for Hardcaml *)

open! Core
open! Hardcaml
open Signal

let nand_ a b = ~:(a &: b)

module Nand = struct
  module I = struct
    type 'a t =
      { a : 'a
      ; b : 'a
      }
    [@@deriving hardcaml]
  end

  module O = struct
    type 'a t = { out : 'a } [@@deriving hardcaml]
  end

  let create _scope (i : _ I.t) : _ O.t = { out = nand_ i.a i.b }

  let hierarchical scope =
    let module Scoped = Hierarchy.In_scope (I) (O) in
    Scoped.hierarchical ~scope ~name:"nand" create
  ;;
end

