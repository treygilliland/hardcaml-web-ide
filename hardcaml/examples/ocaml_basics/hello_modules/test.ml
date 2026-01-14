open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

let test_and outputs expected =
  let out = Bits.to_int !(outputs.Circuit.O.out) in
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
  
  (* Test 1: 0 AND 0 = 0 *)
  inputs.a := Bits.gnd;
  inputs.b := Bits.gnd;
  cycle ();
  test_and outputs 0;

  (* Test 2: 0 AND 1 = 0 *)
  inputs.a := Bits.gnd;
  inputs.b := Bits.vdd;
  cycle ();
  test_and outputs 0;

  (* Test 3: 1 AND 0 = 0 *)
  inputs.a := Bits.vdd;
  inputs.b := Bits.gnd;
  cycle ();
  test_and outputs 0;

  (* Test 4: 1 AND 1 = 1 *)
  inputs.a := Bits.vdd;
  inputs.b := Bits.vdd;
  cycle ();
  test_and outputs 1;
  
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

let%expect_test "Hello Modules test" =
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
