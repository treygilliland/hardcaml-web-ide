open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Dmux

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "Dmux gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp sel expected_a expected_b =
    inputs.inp := Bits.of_int_trunc ~width:1 inp;
    inputs.sel := Bits.of_int_trunc ~width:1 sel;
    Cyclesim.cycle sim;
    let out_a = Bits.to_int_trunc !(outputs.a) in
    let out_b = Bits.to_int_trunc !(outputs.b) in
    if out_a = expected_a && out_b = expected_b then begin
      incr passed;
      printf "PASS: Dmux(%d, sel=%d) = [%d, %d]\n" inp sel out_a out_b
    end else begin
      incr failed;
      printf "FAIL: Dmux(%d, sel=%d) = [%d, %d], expected [%d, %d]\n" 
        inp sel out_a out_b expected_a expected_b
    end
  in

  test 0 0 0 0;
  test 0 1 0 0;
  test 1 0 1 0;
  test 1 1 0 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
