open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Expected answer for the test input. Update this value when using different input. *)
let expected_answer = 0L

let input_data = {|INPUT_DATA|}

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  printf "Input data:\n%s\n" input_data;
  
  (* Reset *)
  inputs.Circuit.I.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Start *)
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* TODO: Add test logic here *)
  cycle ~n:10 ();
  
  let result = Bits.to_int64_trunc !(outputs.Circuit.O.result) in
  printf "Result: %Ld\n" result;
  
  if Int64.(result = expected_answer) then begin
    incr passed;
    printf "PASS: result = %Ld\n" result
  end else begin
    incr failed;
    printf "FAIL: result = %Ld, expected = %Ld\n" result expected_answer
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

let%expect_test "Day 11 Part 2" =
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
