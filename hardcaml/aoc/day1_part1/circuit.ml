(* Day 1 Part 1 - Advent of Code 2025
   
   A dial with positions 0-99 (circular) starts at 50.
   Process L/R rotation commands and count how many times the dial lands on 0. *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let position_bits = 7   (* 0-99 fits in 7 bits *)
let value_bits = 10     (* Input values up to 999 *)
let count_bits = 16     (* Zero counter *)
let initial_position = 50

(* # I/O Interface *)

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a              (* Pulse to initialize/reset the dial *)
    ; direction : 'a          (* 0 = Left, 1 = Right *)
    ; value : 'a [@bits value_bits]  (* Rotation amount 0-999 *)
    ; command_valid : 'a      (* Pulse when a command is ready *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { zero_count : 'a [@bits count_bits]    (* Number of times dial hit 0 *)
    ; position : 'a [@bits position_bits]   (* Current dial position *)
    }
  [@@deriving hardcaml]
end

(* # Helpers *)

(* Compute x mod 100 for values 0-999 using repeated subtraction *)
let mod_100 ~width x =
  let hundred = of_int_trunc ~width 100 in
  let sub_if_ge y = mux2 (y >=: hundred) (y -: hundred) y in
  Fn.apply_n_times ~n:9 sub_if_ge x
;;

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; direction; value; command_valid } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Registers *)
  let%hw_var position = Variable.reg spec ~width:position_bits in
  let%hw_var zero_count = Variable.reg spec ~width:count_bits in

  (* Reduce input value to 0-99 range *)
  let value_mod_100 = mod_100 ~width:value_bits value in

  (* Extend signals for computation (max result is 198) *)
  let compute_width = 8 in
  let hundred = of_int_trunc ~width:compute_width 100 in
  let pos_extended = uresize ~width:compute_width position.value in
  let val_extended = uresize ~width:compute_width value_mod_100 in

  (* Right rotation: (pos + value) mod 100 *)
  let sum = pos_extended +: val_extended in
  let right_result = mux2 (sum >=: hundred) (sum -: hundred) sum in

  (* Left rotation: (pos - value + 100) mod 100 *)
  let pos_plus_100 = pos_extended +: hundred in
  let left_diff = pos_plus_100 -: val_extended in
  let left_result = mux2 (left_diff >=: hundred) (left_diff -: hundred) left_diff in

  (* Select result based on direction: 0 = Left, 1 = Right *)
  let new_position = mux2 direction right_result left_result in
  let new_position_truncated = sel_bottom ~width:position_bits new_position in

  (* Zero detection *)
  let is_zero = new_position_truncated ==: zero position_bits in

  (* State machine logic *)
  compile
    [ when_ start
        [ position <-- of_int_trunc ~width:position_bits initial_position
        ; zero_count <-- zero count_bits
        ]
    ; when_ command_valid
        [ position <-- new_position_truncated
        ; when_ is_zero [ zero_count <-- zero_count.value +: one count_bits ]
        ]
    ];

  (* Outputs *)
  { zero_count = zero_count.value
  ; position = position.value 
  }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day1_part1" create
;;
