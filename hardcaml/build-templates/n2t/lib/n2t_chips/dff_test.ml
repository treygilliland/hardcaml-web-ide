open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Dff

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "DFF" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  (* Clear first *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* DFF stores input and outputs it - simple register behavior
     After cycle, output = input that was present during the cycle *)
  let test inp expected =
    inputs.inp := Bits.of_int_trunc ~width:1 inp;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: DFF(in=%d) -> out=%d\n" inp out
    end else begin
      incr failed;
      printf "FAIL: DFF(in=%d) -> out=%d, expected %d\n" inp out expected
    end
  in

  (* Output equals input from the cycle *)
  test 0 0;
  test 1 1;
  test 1 1;
  test 0 0;
  test 1 1;
  test 0 0;
  test 1 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
