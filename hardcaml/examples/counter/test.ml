open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

let test_count outputs expected =
  let count = Bits.to_unsigned_int !(outputs.Circuit.O.count) in
  if count = expected then begin
    incr passed;
    printf "PASS: count = %d\n" count
  end else begin
    incr failed;
    printf "FAIL: count = %d, expected %d\n" count expected
  end

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  test_count outputs 0;

  (* Count 5 times with enable *)
  inputs.enable := Bits.vdd;
  for i = 1 to 5 do
    cycle ();
    test_count outputs i
  done;

  (* Pause counting - value should stay at 5 *)
  inputs.enable := Bits.gnd;
  cycle ();
  test_count outputs 5;
  cycle ();
  test_count outputs 5;

  (* Resume counting *)
  inputs.enable := Bits.vdd;
  for i = 6 to 10 do
    cycle ();
    test_count outputs i
  done;
  
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

let%expect_test "Counter test" =
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
