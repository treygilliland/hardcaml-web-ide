open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Add16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Add16" =
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
      printf "PASS: Add16(0x%04X, 0x%04X) = 0x%04X\n" a b out
    end else begin
      incr failed;
      printf "FAIL: Add16(0x%04X, 0x%04X) = 0x%04X, expected 0x%04X\n" a b out expected
    end
  in

  test 0x0000 0x0000 0x0000;
  test 0x0001 0x0001 0x0002;
  test 0x0001 0xFFFF 0x0000;  (* overflow wraps *)
  test 0x1234 0x5678 0x68AC;
  test 0xFFFF 0xFFFF 0xFFFE;  (* -1 + -1 = -2 in two's complement *)
  test 0x7FFF 0x0001 0x8000;  (* max positive + 1 = min negative *)
  test 0x0005 0x0003 0x0008;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

