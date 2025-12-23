open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Mux4way16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Mux4Way16 gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b c d sel expected =
    inputs.a := Bits.of_int_trunc ~width:16 a;
    inputs.b := Bits.of_int_trunc ~width:16 b;
    inputs.c := Bits.of_int_trunc ~width:16 c;
    inputs.d := Bits.of_int_trunc ~width:16 d;
    inputs.sel := Bits.of_int_trunc ~width:2 sel;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Mux4Way16(sel=%d) = 0x%04X\n" sel out
    end else begin
      incr failed;
      printf "FAIL: Mux4Way16(sel=%d) = 0x%04X, expected 0x%04X\n" sel out expected
    end
  in

  test 0x1111 0x2222 0x3333 0x4444 0 0x1111;
  test 0x1111 0x2222 0x3333 0x4444 1 0x2222;
  test 0x1111 0x2222 0x3333 0x4444 2 0x3333;
  test 0x1111 0x2222 0x3333 0x4444 3 0x4444;
  test 0xAAAA 0xBBBB 0xCCCC 0xDDDD 0 0xAAAA;
  test 0xAAAA 0xBBBB 0xCCCC 0xDDDD 1 0xBBBB;
  test 0xAAAA 0xBBBB 0xCCCC 0xDDDD 2 0xCCCC;
  test 0xAAAA 0xBBBB 0xCCCC 0xDDDD 3 0xDDDD;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

