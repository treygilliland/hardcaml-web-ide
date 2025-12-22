(* Simple 8-bit counter circuit *)

open! Core
open! Hardcaml
open! Signal

let counter_bits = 8

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; enable : 'a  (* Count when high *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { count : 'a [@bits counter_bits]
    }
  [@@deriving hardcaml]
end

let create scope ({ clock; clear; enable } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  let%hw_var count = Variable.reg spec ~width:counter_bits in

  compile
    [ when_ enable
        [ count <-- count.value +: one counter_bits ]
    ];

  { count = count.value }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"counter" create
;;
