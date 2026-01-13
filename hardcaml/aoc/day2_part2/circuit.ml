(* Day 2 Part 2 - Advent of Code 2025
   
   Find numbers in ranges where ANY repeating pattern of length L exists,
   where num_digits % L == 0.
   
   Examples:
   - "111" matches with L=1 (all same digit)
   - "1212" matches with L=2 (pattern "12" repeats)
   - "123123" matches with L=3 (pattern "123" repeats)
   
   We check pattern lengths L from 1 to floor(num_digits/2).
   
   Circuit receives pre-extracted BCD digits from testbench and checks all patterns.
   Digits are left-padded with zeros to 10 digits. *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let max_digits = 10         (* Support up to 10-digit numbers *)
let digit_bits = 4          (* BCD: 4 bits per digit *)
let count_bits = 4          (* Digit count: 1-10 *)
let value_bits = 40         (* Number value: up to ~1 trillion *)
let sum_bits = 64           (* Sum accumulator *)

(* # I/O Interface *)

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a                              (* Pulse to reset accumulator *)
    ; digits : 'a [@bits (max_digits * digit_bits)]  (* 10 BCD digits, MSB-first, left-padded *)
    ; digit_count : 'a [@bits count_bits]     (* Number of valid digits (1-10) *)
    ; value : 'a [@bits value_bits]           (* The number value to add if match *)
    ; number_valid : 'a                       (* Pulse when a number is ready *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { sum : 'a [@bits sum_bits]               (* Running sum of matching numbers *)
    ; match_count : 'a [@bits 32]             (* Count of matching numbers *)
    }
  [@@deriving hardcaml]
end

(* # Helpers *)

(* Extract a single digit from the packed digits array (0 = leftmost/MSB) *)
let get_digit ~digits ~index =
  let start_bit = (max_digits - 1 - index) * digit_bits in
  select digits ~high:(start_bit + digit_bits - 1) ~low:start_bit
;;

(* Check if pattern of length L repeats to fill exactly num_digits digits.
   For an n-digit number, actual digits are at indices (10-n) to 9.
   For pattern length L, we need n % L == 0 and L <= n/2.
   Check that positions 0, L, 2L, ... all have the same digit, etc. *)
let check_pattern_for_length_and_count ~digits ~digit_count ~pattern_len ~num_digits =
  if num_digits mod pattern_len <> 0 || pattern_len > num_digits / 2 then
    gnd
  else
    let offset = max_digits - num_digits in
    let num_reps = num_digits / pattern_len in
    (* For each position in the pattern, check all repetitions match *)
    let position_checks = List.init pattern_len ~f:(fun pos ->
      (* Get the first occurrence of this position *)
      let first_digit = get_digit ~digits ~index:(offset + pos) in
      (* Compare with all subsequent occurrences *)
      let comparisons = List.init (num_reps - 1) ~f:(fun rep ->
        let idx = offset + pos + (rep + 1) * pattern_len in
        get_digit ~digits ~index:idx ==: first_digit)
      in
      if List.is_empty comparisons then vdd
      else reduce ~f:( &: ) comparisons)
    in
    let pattern_matches = reduce ~f:( &: ) position_checks in
    let length_matches = digit_count ==: of_int_trunc ~width:count_bits num_digits in
    length_matches &: pattern_matches
;;

(* Check if any repeating pattern exists for this number *)
let check_any_pattern ~digits ~digit_count =
  (* For each possible (num_digits, pattern_len) combination *)
  let all_checks = 
    List.concat_map (List.range 2 (max_digits + 1)) ~f:(fun num_digits ->
      List.filter_map (List.range 1 (num_digits / 2 + 1)) ~f:(fun pattern_len ->
        if num_digits mod pattern_len = 0 then
          Some (check_pattern_for_length_and_count ~digits ~digit_count ~pattern_len ~num_digits)
        else
          None))
  in
  if List.is_empty all_checks then gnd
  else reduce ~f:( |: ) all_checks
;;

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; digits; digit_count; value; number_valid } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Registers *)
  let%hw_var sum = Variable.reg spec ~width:sum_bits in
  let%hw_var match_count = Variable.reg spec ~width:32 in

  (* Check if this number has any repeating pattern *)
  let is_match = check_any_pattern ~digits ~digit_count in
  
  (* Extend value to sum width for addition *)
  let value_extended = uresize ~width:sum_bits value in

  (* State machine logic *)
  compile
    [ when_ start
        [ sum <-- zero sum_bits
        ; match_count <-- zero 32
        ]
    ; when_ number_valid
        [ when_ is_match 
            [ sum <-- sum.value +: value_extended
            ; match_count <-- match_count.value +: one 32
            ]
        ]
    ];

  (* Outputs *)
  { sum = sum.value
  ; match_count = match_count.value
  }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day02_part2" create
;;
