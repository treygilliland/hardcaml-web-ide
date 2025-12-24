(* Computer: The Hack computer, consisting of CPU, ROM and RAM
   When reset = 0, the program stored in the ROM executes.
   When reset = 1, the program's execution restarts.
   
   Implement using ROM32K, CPU, and Memory *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; reset : 'a
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc : 'a [@bits 15]
    ; addressM : 'a [@bits 15]
    ; outM : 'a [@bits 16]
    ; writeM : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.rom32k_, cpu_, memory_ *)
  { pc = zero 15; addressM = zero 15; outM = zero 16; writeM = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"computer" create

