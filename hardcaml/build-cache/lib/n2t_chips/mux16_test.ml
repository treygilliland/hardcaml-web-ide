open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Mux16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Mux16 gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b sel expected =
    inputs.a := Bits.of_int_trunc ~width:16 a;
    inputs.b := Bits.of_int_trunc ~width:16 b;
    inputs.sel := Bits.of_int_trunc ~width:1 sel;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Mux16(0x%04X, 0x%04X, sel=%d) = 0x%04X\n" a b sel out
    end else begin
      incr failed;
      printf "FAIL: Mux16(0x%04X, 0x%04X, sel=%d) = 0x%04X, expected 0x%04X\n" a b sel out expected
    end
  in

  test 0x0000 0x0000 0 0x0000;
  test 0x0000 0x0000 1 0x0000;
  test 0x1234 0x5678 0 0x1234;
  test 0x1234 0x5678 1 0x5678;
  test 0xAAAA 0x5555 0 0xAAAA;
  test 0xAAAA 0x5555 1 0x5555;
  test 0xFFFF 0x0000 0 0xFFFF;
  test 0xFFFF 0x0000 1 0x0000;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

