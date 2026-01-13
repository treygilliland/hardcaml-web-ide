(* Day 2 Part 1 - Advent of Code 2025
   
   Find numbers in ranges where:
   - The digit count is even
   - The first half of digits equals the second half
   
   Example: 1212 -> "12" == "12" ✓, 123456 -> "123" != "456" ✗
   
   Circuit receives pre-extracted BCD digits from testbench and checks the pattern.
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

(* Check if first half equals second half for a specific digit count n.
   For n-digit number, actual digits are at indices (10-n) to 9.
   First half: indices (10-n) to (10-n+n/2-1)
   Second half: indices (10-n+n/2) to 9 *)
let check_mirror_for_length ~digits ~digit_count ~n =
  if n mod 2 <> 0 then gnd  (* Must be even length *)
  else
    let offset = max_digits - n in
    let half = n / 2 in
    let matches = 
      List.init half ~f:(fun i ->
        let d1 = get_digit ~digits ~index:(offset + i) in
        let d2 = get_digit ~digits ~index:(offset + i + half) in
        d1 ==: d2)
    in
    let length_matches = digit_count ==: of_int_trunc ~width:count_bits n in
    length_matches &: reduce ~f:( &: ) matches
;;

(* Check if first half equals second half for any valid even digit count *)
let check_mirror ~digits ~digit_count =
  let checks = List.map [2; 4; 6; 8; 10] ~f:(fun n ->
    check_mirror_for_length ~digits ~digit_count ~n)
  in
  reduce ~f:( |: ) checks
;;

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; digits; digit_count; value; number_valid } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Registers *)
  let%hw_var sum = Variable.reg spec ~width:sum_bits in
  let%hw_var match_count = Variable.reg spec ~width:32 in

  (* Check if this number matches the mirror pattern *)
  let is_match = check_mirror ~digits ~digit_count in
  
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
  Scoped.hierarchical ~scope ~name:"day02_part1" create
;;
