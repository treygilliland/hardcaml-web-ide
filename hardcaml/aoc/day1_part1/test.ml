open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Expected answer for the test input. Update this value when using different input. *)
let expected_answer = 3

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

let parse_input input_string =
  String.split_lines input_string
  |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
  |> List.map ~f:parse_command
;;

let input_data = {|INPUT_DATA|}

let ( <--. ) = Bits.( <--. )

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let commands = parse_input input_data in
  printf "Processing %d commands\n" (List.length commands);
  
  let send_command (direction, value) =
    inputs.direction := if direction then Bits.vdd else Bits.gnd;
    inputs.value <--. value;
    inputs.command_valid := Bits.vdd;
    cycle ();
    inputs.command_valid := Bits.gnd;
    cycle ()
  in
  
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  List.iter commands ~f:send_command;
  
  let zero_count = Bits.to_unsigned_int !(outputs.zero_count) in
  let final_position = Bits.to_unsigned_int !(outputs.position) in
  
  if zero_count = expected_answer then begin
    incr passed;
    printf "PASS: zero_count = %d (position = %d)\n" zero_count final_position
  end else begin
    incr failed;
    printf "FAIL: zero_count = %d, expected = %d\n" zero_count expected_answer
  end;

  cycle ~n:2 ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  Harness_utils.write_vcd_if_requested waves
;;

let%expect_test "Day 1 Part 1" =
  passed := 0;
  failed := 0;
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;
