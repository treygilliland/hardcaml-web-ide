open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.And

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "And gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b expected =
    inputs.a := Bits.of_int_trunc ~width:1 a;
    inputs.b := Bits.of_int_trunc ~width:1 b;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: And(%d, %d) = %d\n" a b out
    end else begin
      incr failed;
      printf "FAIL: And(%d, %d) = %d, expected %d\n" a b out expected
    end
  in

  test 0 0 0;
  test 0 1 0;
  test 1 0 0;
  test 1 1 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

