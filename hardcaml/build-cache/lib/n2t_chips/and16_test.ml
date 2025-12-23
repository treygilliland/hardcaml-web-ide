open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.And16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "And16 gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b expected =
    inputs.a := Bits.of_int_trunc ~width:16 a;
    inputs.b := Bits.of_int_trunc ~width:16 b;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: And16(0x%04X, 0x%04X) = 0x%04X\n" a b out
    end else begin
      incr failed;
      printf "FAIL: And16(0x%04X, 0x%04X) = 0x%04X, expected 0x%04X\n" a b out expected
    end
  in

  test 0x0000 0x0000 0x0000;
  test 0xFFFF 0xFFFF 0xFFFF;
  test 0x0000 0xFFFF 0x0000;
  test 0xFFFF 0x0000 0x0000;
  test 0xAAAA 0x5555 0x0000;
  test 0xFF00 0x00FF 0x0000;
  test 0x1234 0xFFFF 0x1234;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

