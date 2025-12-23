open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Dmux4way

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "DMux4Way gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp sel expected_a expected_b expected_c expected_d =
    inputs.inp := Bits.of_int_trunc ~width:1 inp;
    inputs.sel := Bits.of_int_trunc ~width:2 sel;
    Cyclesim.cycle sim;
    let out_a = Bits.to_int_trunc !(outputs.a) in
    let out_b = Bits.to_int_trunc !(outputs.b) in
    let out_c = Bits.to_int_trunc !(outputs.c) in
    let out_d = Bits.to_int_trunc !(outputs.d) in
    if out_a = expected_a && out_b = expected_b && out_c = expected_c && out_d = expected_d then begin
      incr passed;
      printf "PASS: DMux4Way(%d, sel=%d) = [%d, %d, %d, %d]\n" inp sel out_a out_b out_c out_d
    end else begin
      incr failed;
      printf "FAIL: DMux4Way(%d, sel=%d) = [%d, %d, %d, %d], expected [%d, %d, %d, %d]\n" 
        inp sel out_a out_b out_c out_d expected_a expected_b expected_c expected_d
    end
  in

  test 0 0 0 0 0 0;
  test 0 1 0 0 0 0;
  test 0 2 0 0 0 0;
  test 0 3 0 0 0 0;
  test 1 0 1 0 0 0;
  test 1 1 0 1 0 0;
  test 1 2 0 0 1 0;
  test 1 3 0 0 0 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

