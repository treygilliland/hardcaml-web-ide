open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Expected answer for the test input. Update this value when using different input. *)
let expected_answer = 427

(* Parse a problem line like "41x38: 26 26 29 23 21 30" *)
let parse_problem (s : string) : int * int * int =
  let s = String.strip s in
  let parts = String.lsplit2_exn s ~on:':' in
  let dims, counts_str = parts in
  (* Parse dimensions "WxH" *)
  let dim_parts = String.lsplit2_exn dims ~on:'x' in
  let width = Int.of_string (fst dim_parts) in
  let height = Int.of_string (snd dim_parts) in
  (* Parse counts and sum them *)
  let counts = 
    String.strip counts_str
    |> String.split ~on:' '
    |> List.filter ~f:(fun s -> not (String.is_empty s))
    |> List.map ~f:Int.of_string
  in
  let total_count = List.fold counts ~init:0 ~f:(+) in
  (width, height, total_count)
;;

let parse_input input_string =
  let lines = String.split_lines input_string in
  (* Skip first 30 lines (shape definitions), problems start at line 31 (index 30) *)
  let problem_lines = List.drop lines 30 in
  List.filter_map problem_lines ~f:(fun line ->
    let line = String.strip line in
    if String.is_empty line then None
    else Some (parse_problem line))
;;

let input_data = In_channel.read_all "input.txt"

let ( <--. ) = Bits.( <--. )

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let problems = parse_input input_data in
  printf "Processing %d problems\n" (List.length problems);
  
  let send_problem (width, height, total_count) =
    inputs.width <--. width;
    inputs.height <--. height;
    inputs.total_count <--. total_count;
    inputs.problem_valid := Bits.vdd;
    cycle ();
    inputs.problem_valid := Bits.gnd;
    cycle ()
  in
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Start - initialize counter *)
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* Process all problems *)
  List.iter problems ~f:send_problem;
  
  let possible_count = Bits.to_unsigned_int !(outputs.possible_count) in
  
  printf "Answer: %d regions can fit all presents\n" possible_count;
  
  if possible_count = expected_answer then begin
    incr passed;
    printf "PASS: possible_count = %d\n" possible_count
  end else begin
    incr failed;
    printf "FAIL: possible_count = %d, expected = %d\n" possible_count expected_answer
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

let%expect_test "Day 12 Part 1" =
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
