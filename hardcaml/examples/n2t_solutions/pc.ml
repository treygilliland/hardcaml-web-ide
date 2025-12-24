(* PC: 16-bit Program Counter
   if      reset(t): out(t+1) = 0
   else if load(t):  out(t+1) = in(t)
   else if inc(t):   out(t+1) = out(t) + 1
   else              out(t+1) = out(t)
   
   Implementation:
   - Inc16 for increment
   - Chain of Mux16 in reverse priority order (inc, load, reset)
   - Register with load=true (always update)
   Uses reg_fb for feedback loop *)

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

let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let out = reg_fb spec ~width:16 ~f:(fun feedback ->
    let open N2t_chips in
    let incval = inc16_ scope feedback in
    let o1 = mux16_ scope feedback incval i.inc in
    let o2 = mux16_ scope o1 i.inp i.load in
    mux16_ scope o2 (zero 16) i.reset)
  in
  { out }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"pc" create

