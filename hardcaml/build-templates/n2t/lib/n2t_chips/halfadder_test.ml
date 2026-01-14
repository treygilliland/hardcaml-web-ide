open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Halfadder

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "Half Adder" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b expected_sum expected_carry =
    inputs.a := Bits.of_int_trunc ~width:1 a;
    inputs.b := Bits.of_int_trunc ~width:1 b;
    Cyclesim.cycle sim;
    let sum = Bits.to_int_trunc !(outputs.sum) in
    let carry = Bits.to_int_trunc !(outputs.carry) in
    if sum = expected_sum && carry = expected_carry then begin
      incr passed;
      printf "PASS: HalfAdder(%d, %d) = sum:%d, carry:%d\n" a b sum carry
    end else begin
      incr failed;
      printf "FAIL: HalfAdder(%d, %d) = sum:%d, carry:%d, expected sum:%d, carry:%d\n" 
        a b sum carry expected_sum expected_carry
    end
  in

  test 0 0 0 0;
  test 0 1 1 0;
  test 1 0 1 0;
  test 1 1 0 1;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
