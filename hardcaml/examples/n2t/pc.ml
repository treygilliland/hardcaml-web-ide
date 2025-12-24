(* PC: 16-bit Program Counter
   if      reset(t): out(t+1) = 0
   else if load(t):  out(t+1) = in(t)
   else if inc(t):   out(t+1) = out(t) + 1
   else              out(t+1) = out(t)
   
   Implement using Register, Inc16, and Mux16 chips *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    ; inc : 'a
    ; reset : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.register_, inc16_, mux16_ *)
  { out = zero 16 }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"pc" create

