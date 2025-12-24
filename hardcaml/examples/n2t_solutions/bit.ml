(* Bit: 1-bit register with load enable
   if load(t) then out(t+1) = in(t)
   else out(t+1) = out(t)
   
   Implementation: Mux(a=feedback, b=in, sel=load) -> DFF -> out
   Uses reg_fb for feedback loop *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a
    ; load : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let out = reg_fb spec ~width:1 ~f:(fun feedback ->
    N2t_chips.mux_ scope feedback i.inp i.load)
  in
  { out }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"bit" create

