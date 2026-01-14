(* PC: 16-bit Program Counter
   if      reset(t): out(t+1) = 0
   else if load(t):  out(t+1) = in(t)
   else if inc(t):   out(t+1) = out(t) + 1
   else              out(t+1) = out(t) *)

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
  let _ = scope in
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let open Always in
  let%hw_var counter = Variable.reg spec ~width:16 in
  compile [
    if_ i.reset [
      counter <-- zero 16
    ] @@ elif i.load [
      counter <-- i.inp
    ] @@ elif i.inc [
      counter <-- counter.value +: one 16
    ] []
  ];
  { out = counter.value }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"pc" create
