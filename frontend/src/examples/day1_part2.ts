import type { HardcamlExample } from "./examples";

/**
 * Advent of FPGA 2025 - Day 1 Part 2
 *
 * A dial with positions 0-99 (circular) starts at 50.
 * Process L/R rotation commands and count how many times the dial CROSSES 0.
 * This includes crossings during rotations, not just landing on 0.
 *
 * This example demonstrates:
 * - Integer division in hardware (div_100)
 * - Counting full rotations (laps)
 * - Edge detection for partial crossings
 */
export const day1Part2Example: HardcamlExample = {
  name: "AoC Day 1 Part 2",
  description:
    "Count how many times a circular dial crosses position 0 during rotations (including full laps)",
  difficulty: "advanced",
  category: "advent",

  circuit: `(* Day 1 Part 2 - Advent of Code 2025
   
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
;;`,

  interface: `(** Day 1 Part 2 - Advent of Code 2025
   
    A dial with positions 0-99 (circular) starts at 50.
    Process L/R rotation commands and count how many times the dial CROSSES 0.
    This includes crossings during rotations, not just landing on 0. *)

open! Core
open! Hardcaml

val position_bits : int
val value_bits : int
val count_bits : int
val initial_position : int

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; direction : 'a
    ; value : 'a
    ; command_valid : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { zero_crossings : 'a
    ; position : 'a
    }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t`,

  test: `open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

(* Parse a single command like "L68" or "R30" *)
let parse_command (s : string) : bool * int =
  let s = String.strip s in
  if String.length s < 2 then failwith ("Invalid command: " ^ s);
  let dir_char = String.get s 0 in
  let value = Int.of_string (String.sub s ~pos:1 ~len:(String.length s - 1)) in
  let direction = 
    match dir_char with
    | 'L' -> false
    | 'R' -> true
    | _ -> failwith ("Invalid direction: " ^ String.make 1 dir_char)
  in
  (direction, value)
;;

(* Parse input from the Input tab - each line is a command *)
let parse_input input_string =
  String.split_lines input_string
  |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
  |> List.map ~f:parse_command
;;

(* The input data is provided via the Input tab *)
let input_data = {|INPUT_DATA|}

let ( <--. ) = Bits.( <--. )

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let commands = parse_input input_data in
  print_s [%message "Processing commands" (List.length commands : int)];
  
  let send_command (direction, value) =
    inputs.direction := if direction then Bits.vdd else Bits.gnd;
    inputs.value <--. value;
    inputs.command_valid := Bits.vdd;
    cycle ();
    inputs.command_valid := Bits.gnd;
    cycle ()
  in
  
  (* Initialize *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* Process all commands *)
  List.iter commands ~f:send_command;
  
  (* Report results *)
  let zero_crossings = Bits.to_unsigned_int !(outputs.zero_crossings) in
  let final_position = Bits.to_unsigned_int !(outputs.position) in
  print_s [%message "Result" (zero_crossings : int) (final_position : int)];
  
  cycle ~n:2 ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  (* Save VCD to file for the backend to read *)
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"
;;

let%expect_test "Day 1 Part 2" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:\`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;`,

  input: `L68
L30
R48
L5
R60
L55
L1
L99
R14
L82`,
};

