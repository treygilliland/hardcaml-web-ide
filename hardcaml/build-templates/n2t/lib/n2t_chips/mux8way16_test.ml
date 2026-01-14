open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Mux8way16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "Mux8Way16 gate" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test a b c d e f g h sel expected =
    inputs.a := Bits.of_int_trunc ~width:16 a;
    inputs.b := Bits.of_int_trunc ~width:16 b;
    inputs.c := Bits.of_int_trunc ~width:16 c;
    inputs.d := Bits.of_int_trunc ~width:16 d;
    inputs.e := Bits.of_int_trunc ~width:16 e;
    inputs.f := Bits.of_int_trunc ~width:16 f;
    inputs.g := Bits.of_int_trunc ~width:16 g;
    inputs.h := Bits.of_int_trunc ~width:16 h;
    inputs.sel := Bits.of_int_trunc ~width:3 sel;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Mux8Way16(sel=%d) = 0x%04X\n" sel out
    end else begin
      incr failed;
      printf "FAIL: Mux8Way16(sel=%d) = 0x%04X, expected 0x%04X\n" sel out expected
    end
  in

  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 0 0x1111;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 1 0x2222;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 2 0x3333;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 3 0x4444;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 4 0x5555;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 5 0x6666;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 6 0x7777;
  test 0x1111 0x2222 0x3333 0x4444 0x5555 0x6666 0x7777 0x8888 7 0x8888;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
