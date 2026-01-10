open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Inc16

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Inc16" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp expected =
    inputs.inp := Bits.of_int_trunc ~width:16 inp;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Inc16(0x%04X) = 0x%04X\n" inp out
    end else begin
      incr failed;
      printf "FAIL: Inc16(0x%04X) = 0x%04X, expected 0x%04X\n" inp out expected
    end
  in

  test 0x0000 0x0001;
  test 0x0001 0x0002;
  test 0x00FF 0x0100;
  test 0x7FFF 0x8000;
  test 0xFFFF 0x0000;  (* overflow wraps *)
  test 0x1234 0x1235;
  test 0xFFFE 0xFFFF;
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
