(* Day 3 Part 2 - Advent of Code 2025
   
   Find 12 sequential maximum digits from each line, building a 12-digit number.
   For each line:
   1. Start at position -1, N = 11
   2. Repeat 12 times:
      - Find max digit in range [i+1, len-N]
      - Update i to position of that max
      - Add digit × 10^N to result
      - Decrement N
   3. Accumulate line results *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let digit_bits = 4        (* Digits 0-9 *)
let pos_bits = 8          (* Position counter, max 256 digits per line *)
let max_line_length = 128 (* Maximum digits per line *)
let num_digits = 12       (* Number of digits to find *)
let digit_count_bits = 4  (* 0-11 fits in 4 bits *)
let result_bits = 64      (* Accumulated result *)

(* State machine states *)
let state_idle = 0
let state_receive = 1
let state_find_max = 2     (* Scanning for max in current window *)
let state_accumulate = 3   (* Add digit to line result *)
let state_done = 4         (* Add line result to total *)
let state_bits = 3

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

  (* State machine *)
  let%hw_var state = Variable.reg spec ~width:state_bits in

  (* Digit buffer - store all digits of current line *)
  let digit_buffer = Array.init max_line_length ~f:(fun _ ->
    Variable.reg spec ~width:digit_bits
  ) in

  (* Line tracking *)
  let%hw_var line_length = Variable.reg spec ~width:pos_bits in
  let%hw_var write_pos = Variable.reg spec ~width:pos_bits in

  (* Max-finding state *)
  let%hw_var search_pos = Variable.reg spec ~width:pos_bits in      (* Current scan position *)
  let%hw_var search_end = Variable.reg spec ~width:pos_bits in      (* End of search window *)
  let%hw_var current_max = Variable.reg spec ~width:digit_bits in   (* Max found so far *)
  let%hw_var max_pos = Variable.reg spec ~width:pos_bits in         (* Position of max *)
  let%hw_var digit_count = Variable.reg spec ~width:digit_count_bits in (* Which digit 0-11 *)

  (* Results *)
  let%hw_var line_result = Variable.reg spec ~width:result_bits in
  let%hw_var result_acc = Variable.reg spec ~width:result_bits in

  (* Powers of 10 lookup table for building 12-digit number *)
  let powers_of_10 = 
    [| 100000000000L; 10000000000L; 1000000000L; 100000000L; 10000000L; 
       1000000L; 100000L; 10000L; 1000L; 100L; 10L; 1L |]
    |> Array.map ~f:(fun v -> of_int64_trunc ~width:result_bits v)
  in
  let power_of_10 = mux digit_count.value (Array.to_list powers_of_10) in

  (* Read digit from buffer at search_pos *)
  let buffer_signals = Array.map digit_buffer ~f:(fun v -> v.value) in
  let current_digit = mux search_pos.value (Array.to_list buffer_signals) in

  (* Check if current digit is greater than current max *)
  let is_new_max = current_digit >: current_max.value in

  (* Check if scan is complete (search_pos >= search_end) *)
  let scan_done = search_pos.value >=: search_end.value in

  (* Compute contribution: digit * 10^(11 - digit_count) *)
  let digit_extended = uresize ~width:result_bits current_max.value in
  let digit_contribution = sel_bottom ~width:result_bits (digit_extended *: power_of_10) in

  (* Check if all 12 digits found - check against 11 since we use OLD value before increment *)
  let all_digits_found = digit_count.value ==: of_int_trunc ~width:digit_count_bits (num_digits - 1) in

  (* State machine logic *)
  compile
    [ when_ start
        [ state <-- of_int_trunc ~width:state_bits state_receive
        ; line_length <-- zero pos_bits
        ; write_pos <-- zero pos_bits
        ; line_result <-- zero result_bits
        ; result_acc <-- zero result_bits
        ]
    ; switch state.value
        [ ( of_int_trunc ~width:state_bits state_idle
          , [ (* Wait for start *) ] )
        
        ; ( of_int_trunc ~width:state_bits state_receive
          , [ when_ digit_valid
                [ (* Store digit in buffer *)
                  (let writes = Array.mapi digit_buffer ~f:(fun i var ->
                    when_ (write_pos.value ==: of_int_trunc ~width:pos_bits i)
                      [ var <-- digit ]
                  ) in
                  proc (Array.to_list writes))
                ; write_pos <-- write_pos.value +: one pos_bits
                ]
            ; when_ end_of_line
                [ line_length <-- write_pos.value
                ; write_pos <-- zero pos_bits
                ; digit_count <-- zero digit_count_bits
                ; search_pos <-- zero pos_bits
                (* search_end = line_length - (11 - digit_count) = line_length - 11 + 0 *)
                ; search_end <-- write_pos.value -: of_int_trunc ~width:pos_bits 11
                ; current_max <-- zero digit_bits
                ; max_pos <-- zero pos_bits
                ; line_result <-- zero result_bits
                ; state <-- of_int_trunc ~width:state_bits state_find_max
                ]
            ] )
        
        ; ( of_int_trunc ~width:state_bits state_find_max
          , [ if_ scan_done
                [ (* Move to accumulate the found max *)
                  state <-- of_int_trunc ~width:state_bits state_accumulate
                ]
                [ (* Continue scanning *)
                  when_ is_new_max
                    [ current_max <-- current_digit
                    ; max_pos <-- search_pos.value
                    ]
                ; search_pos <-- search_pos.value +: one pos_bits
                ]
            ] )
        
        ; ( of_int_trunc ~width:state_bits state_accumulate
          , [ (* Add digit contribution to line result *)
              line_result <-- line_result.value +: digit_contribution
            ; digit_count <-- digit_count.value +: one digit_count_bits
            
            (* Setup for next digit search - compute next_search_start inline *)
            ; search_pos <-- max_pos.value +: one pos_bits
            ; max_pos <-- max_pos.value +: one pos_bits  (* Initialize max_pos to search start *)
            (* search_end = line_length - (11 - digit_count) where digit_count is now incremented *)
            ; search_end <-- line_length.value -: 
                (of_int_trunc ~width:pos_bits 11 -: uresize ~width:pos_bits digit_count.value -: one pos_bits)
            ; current_max <-- zero digit_bits
            
            ; if_ all_digits_found
                [ state <-- of_int_trunc ~width:state_bits state_done ]
                [ state <-- of_int_trunc ~width:state_bits state_find_max ]
            ] )
        
        ; ( of_int_trunc ~width:state_bits state_done
          , [ (* Add line result to total and return to receive *)
              result_acc <-- result_acc.value +: line_result.value
            ; state <-- of_int_trunc ~width:state_bits state_receive
            ] )
        ]
    ];

  (* Output *)
  { result = result_acc.value }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day3_part2" create
;;
