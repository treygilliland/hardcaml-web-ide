open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Parse a line of digits into a list of ints *)
let parse_line (s : string) : int list =
  let s = String.strip s in
  String.to_list s
  |> List.map ~f:(fun c -> Char.get_digit_exn c)
;;

(* Parse all lines from input *)
let parse_input input_string =
  String.split_lines input_string
  |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
  |> List.map ~f:parse_line
;;

(* Compute expected result using the Python algorithm *)
let compute_expected (lines : int list list) : int =
  List.fold lines ~init:0 ~f:(fun acc nums ->
    if List.length nums < 2 then acc
    else
      let nums_excl_last = List.take nums (List.length nums - 1) in
      let x = List.fold nums_excl_last ~init:0 ~f:Int.max in
      let i = 
        match List.findi nums_excl_last ~f:(fun _ v -> v = x) with
        | Some (idx, _) -> idx
        | None -> 0
      in
      let nums_after_i = List.drop nums (i + 1) in
      let y = List.fold nums_after_i ~init:0 ~f:Int.max in
      acc + (x * 10 + y)
  )
;;

let input_data = {|INPUT_DATA|}

let ( <--. ) = Bits.( <--. )

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let lines = parse_input input_data in
  let expected = compute_expected lines in
  printf "Processing %d lines\n" (List.length lines);
  printf "Expected result: %d\n" expected;
  
  (* Helper to send a single digit *)
  let send_digit d =
    inputs.digit <--. d;
    inputs.digit_valid := Bits.vdd;
    cycle ();
    inputs.digit_valid := Bits.gnd
  in
  
  (* Helper to signal end of line *)
  let send_end_of_line () =
    inputs.end_of_line := Bits.vdd;
    cycle ();
    inputs.end_of_line := Bits.gnd
  in
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Start *)
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* Process each line *)
  List.iter lines ~f:(fun digits ->
    (* Send each digit *)
    List.iter digits ~f:send_digit;
    (* Signal end of line *)
    send_end_of_line ()
  );
  
  (* Allow result to settle *)
  cycle ~n:2 ();
  
  let result = Bits.to_int_trunc !(outputs.result) in
  printf "Circuit result: %d\n" result;
  
  if result = expected then begin
    incr passed;
    printf "PASS: result = %d\n" result
  end else begin
    incr failed;
    printf "FAIL: result = %d, expected = %d\n" result expected
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

let%expect_test "Day 3 Part 1" =
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
