(* Day 3 Part 1 - Advent of Code 2025
   
   For each line of digits:
   1. Find x = max digit in positions 0 to n-2 (exclude last)
   2. Find i = first position where digit equals x
   3. Find y = max digit from position i+1 to n-1 (include last)
   4. Add x * 10 + y to running total *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let digit_bits = 4     (* Digits 0-9 *)
let pos_bits = 8       (* Position counter, max ~256 digits per line *)
let result_bits = 32   (* Accumulated result *)

(* # I/O Interface *)

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a                        (* Reset and start processing *)
    ; digit : 'a [@bits digit_bits]     (* Current digit 0-9 *)
    ; digit_valid : 'a                  (* Pulse when digit is ready *)
    ; end_of_line : 'a                  (* Pulse at end of each line *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { result : 'a [@bits result_bits]   (* Accumulated sum *)
    }
  [@@deriving hardcaml]
end

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; digit; digit_valid; end_of_line } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Current line state registers *)
  let%hw_var max_so_far = Variable.reg spec ~width:digit_bits in
  let%hw_var max_pos = Variable.reg spec ~width:pos_bits in
  let%hw_var max_after = Variable.reg spec ~width:digit_bits in
  let%hw_var pos = Variable.reg spec ~width:pos_bits in

  (* Previous state registers (for exclude-last-digit logic) *)
  let%hw_var prev_max = Variable.reg spec ~width:digit_bits in
  let%hw_var prev_max_pos = Variable.reg spec ~width:pos_bits in
  let%hw_var prev_max_after = Variable.reg spec ~width:digit_bits in
  let%hw_var prev_digit = Variable.reg spec ~width:digit_bits in

  (* Accumulated result *)
  let%hw_var result_acc = Variable.reg spec ~width:result_bits in

  (* Compute new max_after: if we're past max_pos, track max of digits after it *)
  let new_max_after = mux2 (digit >: max_after.value) digit max_after.value in

  (* Determine if this digit becomes the new max *)
  let is_new_max = digit >: max_so_far.value in

  (* Compute y value at end of line:
     y = max(prev_max_after, prev_digit) if prev_max_pos < pos-1, else prev_digit
     Since we need digits AFTER prev_max_pos, including the last digit *)
  let y_candidate = mux2 (prev_digit.value >: prev_max_after.value) 
                         prev_digit.value 
                         prev_max_after.value in
  
  (* If prev_max_pos >= pos-1 (i.e., the max was found at or after position pos-2),
     then there are no digits between max and the second-to-last, so y = prev_digit *)
  let pos_minus_one = pos.value -: one pos_bits in
  let y_value = mux2 (prev_max_pos.value >=: pos_minus_one) prev_digit.value y_candidate in

  (* Compute line result: x * 10 + y 
     x is at most 9, so x*10 is at most 90, and x*10+y is at most 99.
     Use 8-bit computation to avoid width issues with multiplication. *)
  let compute_width = 8 in
  let x_small = uresize ~width:compute_width prev_max.value in
  let y_small = uresize ~width:compute_width y_value in
  let ten = of_int_trunc ~width:compute_width 10 in
  let x_times_10 = sel_bottom ~width:compute_width (x_small *: ten) in
  let line_result_small = x_times_10 +: y_small in
  let line_result = uresize ~width:result_bits line_result_small in

  (* State machine logic *)
  compile
    [ when_ start
        [ (* Reset all state *)
          max_so_far <-- zero digit_bits
        ; max_pos <-- zero pos_bits
        ; max_after <-- zero digit_bits
        ; pos <-- zero pos_bits
        ; prev_max <-- zero digit_bits
        ; prev_max_pos <-- zero pos_bits
        ; prev_max_after <-- zero digit_bits
        ; prev_digit <-- zero digit_bits
        ; result_acc <-- zero result_bits
        ]
    ; when_ digit_valid
        [ (* Save current state to prev_* before updating *)
          prev_max <-- max_so_far.value
        ; prev_max_pos <-- max_pos.value
        ; prev_max_after <-- max_after.value
        ; prev_digit <-- digit
        
        (* Update current state *)
        ; if_ is_new_max
            [ max_so_far <-- digit
            ; max_pos <-- pos.value
            ; max_after <-- zero digit_bits  (* Reset - no digits after new max yet *)
            ]
            [ (* Not a new max - update max_after if we're past max_pos *)
              when_ (pos.value >: max_pos.value)
                [ max_after <-- new_max_after ]
            ]
        ; pos <-- pos.value +: one pos_bits
        ]
    ; when_ end_of_line
        [ (* Add line result to accumulator *)
          result_acc <-- result_acc.value +: line_result
        
        (* Reset line state for next line *)
        ; max_so_far <-- zero digit_bits
        ; max_pos <-- zero pos_bits
        ; max_after <-- zero digit_bits
        ; pos <-- zero pos_bits
        ]
    ];

  (* Output *)
  { result = result_acc.value }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day3_part1" create
;;
