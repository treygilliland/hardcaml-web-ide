open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

let test_output outputs expected =
  let out = Bits.to_unsigned_int !(outputs.Circuit.O.out) in
  if out = expected then begin
    incr passed;
    printf "PASS: out = %d\n" out
  end else begin
    incr failed;
    printf "FAIL: out = %d, expected %d\n" out expected
  end

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  
  (* Test 1: Pass through value 42 *)
  inputs.data := Bits.of_int_trunc ~width:8 42;
  cycle ();
  test_output outputs 42;

  (* Test 2: Pass through value 0 *)
  inputs.data := Bits.of_int_trunc ~width:8 0;
  cycle ();
  test_output outputs 0;

  (* Test 3: Pass through value 255 (max 8-bit) *)
  inputs.data := Bits.of_int_trunc ~width:8 255;
  cycle ();
  test_output outputs 255;
  
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  Harness_utils.write_vcd_if_requested waves
;;

let%expect_test "Hello Types test" =
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
