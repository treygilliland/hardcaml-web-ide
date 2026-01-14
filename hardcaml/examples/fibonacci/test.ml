open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

let test_fibonacci sim inputs outputs n expected =
  let cycle () = Cyclesim.cycle sim in
  
  (* Reset *)
  inputs.Circuit.I.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();

  (* Start computation *)
  inputs.start := Bits.vdd;
  inputs.n := Bits.of_unsigned_int ~width:8 n;
  cycle ();
  inputs.start := Bits.gnd;

  (* Wait for done *)
  let max_cycles = 50 in
  let rec wait_done cycles_left =
    if cycles_left = 0 then begin
      incr failed;
      printf "FAIL: fibonacci(%d) timed out\n" n
    end else if Bits.to_bool !(outputs.Circuit.O.done_) then begin
      let result = Bits.to_unsigned_int !(outputs.result) in
      if result = expected then begin
        incr passed;
        printf "PASS: fibonacci(%d) = %d\n" n result
      end else begin
        incr failed;
        printf "FAIL: fibonacci(%d) = %d, expected %d\n" n result expected
      end
    end else begin
      cycle ();
      wait_done (cycles_left - 1)
    end
  in
  wait_done max_cycles

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  
  (* Test various fibonacci numbers *)
  test_fibonacci sim inputs outputs 0 1;
  test_fibonacci sim inputs outputs 1 1;
  test_fibonacci sim inputs outputs 2 2;
  test_fibonacci sim inputs outputs 5 8;
  test_fibonacci sim inputs outputs 10 89;
  
  Cyclesim.cycle sim
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  Harness_utils.write_vcd_if_requested waves
;;

let%expect_test "Fibonacci test" =
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
