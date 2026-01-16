(* Day 1 Part 2 - Advent of Code 2025
   
   A dial with positions 0-99 (circular) starts at 50.
   Process L/R rotation commands and count how many times the dial CROSSES 0.
   This includes crossings during rotations, not just landing on 0. *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let position_bits = 7   (* 0-99 fits in 7 bits *)
let value_bits = 10     (* Input values up to 999 *)
let count_bits = 16     (* Zero crossing counter *)
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
    { zero_crossings : 'a [@bits count_bits]  (* Number of times dial crossed 0 *)
    ; position : 'a [@bits position_bits]     (* Current dial position *)
    }
  [@@deriving hardcaml]
end

(* # Helpers *)

(* Compute x / 100 for values 0-999 (result is 0-9) *)
let div_100 ~width x =
  let hundred = of_int_trunc ~width 100 in
  (* Count how many times we can subtract 100 *)
  let rec count_subs acc remaining n =
    if n = 0 then acc
    else
      let can_sub = remaining >=: hundred in
      let new_remaining = mux2 can_sub (remaining -: hundred) remaining in
      let new_acc = mux2 can_sub (acc +: one 4) acc in
      count_subs new_acc new_remaining (n - 1)
  in
  count_subs (zero 4) x 9
;;

(* Compute x mod 100 for values 0-999 using repeated subtraction *)
let mod_100 ~width x =
  let hundred = of_int_trunc ~width 100 in
  let sub_if_ge y = mux2 (y >=: hundred) (y -: hundred) y in
  Fn.apply_n_times ~n:9 sub_if_ge x
;;

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; direction; value; command_valid } : _ I.t) : _ O.t =
  let _ = scope in  (* unused but required by let%hw_var *)
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Registers *)
  let%hw_var position = Variable.reg spec ~width:position_bits in
  let%hw_var zero_crossings = Variable.reg spec ~width:count_bits in

  (* Compute value / 100 and value % 100 *)
  let full_laps = div_100 ~width:value_bits value in
  let value_mod_100 = mod_100 ~width:value_bits value in

  (* Extend signals for computation (max result is 198) *)
  let compute_width = 8 in
  let hundred = of_int_trunc ~width:compute_width 100 in
  let pos_extended = uresize ~width:compute_width position.value in
  let val_extended = uresize ~width:compute_width value_mod_100 in

  (* Right rotation: (pos + value) mod 100 *)
  let sum = pos_extended +: val_extended in
  let right_crosses_once = sum >=: hundred in
  let right_result = mux2 right_crosses_once (sum -: hundred) sum in

  (* Left rotation: (pos - value + 100) mod 100 *)
  let pos_plus_100 = pos_extended +: hundred in
  let left_diff = pos_plus_100 -: val_extended in
  (* Left crosses zero if pos > 0 and pos - value <= 0, i.e., value >= pos and pos > 0 *)
  let pos_is_positive = pos_extended >: zero compute_width in
  let left_crosses_once = pos_is_positive &: (val_extended >=: pos_extended) in
  let left_result = mux2 (left_diff >=: hundred) (left_diff -: hundred) left_diff in

  (* Select result based on direction: 0 = Left, 1 = Right *)
  let new_position = mux2 direction right_result left_result in
  let new_position_truncated = sel_bottom ~width:position_bits new_position in

  (* Count crossings: full laps + additional crossing from partial rotation *)
  let extra_crossing = mux2 direction right_crosses_once left_crosses_once in
  let crossings_this_command = uresize ~width:count_bits full_laps +: uresize ~width:count_bits extra_crossing in

  (* State machine logic *)
  compile
    [ when_ start
        [ position <-- of_int_trunc ~width:position_bits initial_position
        ; zero_crossings <-- zero count_bits
        ]
    ; when_ command_valid
        [ position <-- new_position_truncated
        ; zero_crossings <-- zero_crossings.value +: crossings_this_command
        ]
    ];

  (* Outputs *)
  { zero_crossings = zero_crossings.value
  ; position = position.value 
  }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day1_part2" create
;;

