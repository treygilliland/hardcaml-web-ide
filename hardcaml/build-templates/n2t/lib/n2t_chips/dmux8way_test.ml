open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Dmux8way

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "DMux8Way gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp sel ea eb ec ed ee ef eg eh =
    inputs.inp := Bits.of_int_trunc ~width:1 inp;
    inputs.sel := Bits.of_int_trunc ~width:3 sel;
    Cyclesim.cycle sim;
    let oa = Bits.to_int_trunc !(outputs.a) in
    let ob = Bits.to_int_trunc !(outputs.b) in
    let oc = Bits.to_int_trunc !(outputs.c) in
    let od = Bits.to_int_trunc !(outputs.d) in
    let oe = Bits.to_int_trunc !(outputs.e) in
    let of_ = Bits.to_int_trunc !(outputs.f) in
    let og = Bits.to_int_trunc !(outputs.g) in
    let oh = Bits.to_int_trunc !(outputs.h) in
    if oa = ea && ob = eb && oc = ec && od = ed && oe = ee && of_ = ef && og = eg && oh = eh then begin
      incr passed;
      printf "PASS: DMux8Way(%d, sel=%d) = [%d,%d,%d,%d,%d,%d,%d,%d]\n" inp sel oa ob oc od oe of_ og oh
    end else begin
      incr failed;
      printf "FAIL: DMux8Way(%d, sel=%d) = [%d,%d,%d,%d,%d,%d,%d,%d], expected [%d,%d,%d,%d,%d,%d,%d,%d]\n" 
        inp sel oa ob oc od oe of_ og oh ea eb ec ed ee ef eg eh
    end
  in

  test 0 0 0 0 0 0 0 0 0 0;
  test 0 7 0 0 0 0 0 0 0 0;
  test 1 0 1 0 0 0 0 0 0 0;
  test 1 1 0 1 0 0 0 0 0 0;
  test 1 2 0 0 1 0 0 0 0 0;
  test 1 3 0 0 0 1 0 0 0 0;
  test 1 4 0 0 0 0 1 0 0 0;
  test 1 5 0 0 0 0 0 1 0 0;
  test 1 6 0 0 0 0 0 0 1 0;
  test 1 7 0 0 0 0 0 0 0 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
