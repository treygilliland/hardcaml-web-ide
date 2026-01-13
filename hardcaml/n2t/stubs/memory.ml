(* Memory: The complete address space of the Hack computer's memory
   Address space:
   - 0x0000-0x3FFF: RAM16K (16384 words)
   - 0x4000-0x5FFF: Screen (8192 words)  
   - 0x6000: Keyboard (1 word)
   
   Implement using RAM16K, Screen, Keyboard, DMux, Mux16 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16] [@rtlname "in"]
    ; load : 'a
    ; address : 'a [@bits 15]
    ; key : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.ram16k_, screen_, keyboard_, dmux_, mux16_ *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"memory" create
