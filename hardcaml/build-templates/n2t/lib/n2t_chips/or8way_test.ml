open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Or8way

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "Or8Way gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a expected =
    inputs.a := Bits.of_int_trunc ~width:8 a;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Or8Way(0x%02X) = %d\n" a out
    end else begin
      incr failed;
      printf "FAIL: Or8Way(0x%02X) = %d, expected %d\n" a out expected
    end
  in

  test 0x00 0;
  test 0x01 1;
  test 0x02 1;
  test 0x10 1;
  test 0x80 1;
  test 0xFF 1;
  test 0x55 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
