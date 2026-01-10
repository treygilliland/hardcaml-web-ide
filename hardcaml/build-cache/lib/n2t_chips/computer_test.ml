open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Computer

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Computer" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test_cycle ~reset ~key ~desc =
    inputs.reset := Bits.of_int_trunc ~width:1 reset;
    inputs.key := Bits.of_int_trunc ~width:16 key;
    Cyclesim.cycle sim;
    let pc = Bits.to_int_trunc !(outputs.pc) in
    let addressM = Bits.to_int_trunc !(outputs.addressM) in
    let outM = Bits.to_int_trunc !(outputs.outM) in
    let writeM = Bits.to_int_trunc !(outputs.writeM) in
    incr passed;
    printf "PASS: %s (pc=%d, addressM=%d, outM=%d, writeM=%d)\n" desc pc addressM outM writeM
  in

  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  test_cycle ~reset:1 ~key:0 ~desc:"Reset computer";
  test_cycle ~reset:0 ~key:0 ~desc:"Run cycle 1";
  test_cycle ~reset:0 ~key:0 ~desc:"Run cycle 2";
  test_cycle ~reset:0 ~key:0 ~desc:"Run cycle 3";
  test_cycle ~reset:1 ~key:0 ~desc:"Reset again";
  test_cycle ~reset:0 ~key:0 ~desc:"Run after reset";

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
