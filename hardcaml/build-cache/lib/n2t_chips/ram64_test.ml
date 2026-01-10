open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Ram64

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "RAM64" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let write addr value =
    inputs.inp := Bits.of_int_trunc ~width:16 value;
    inputs.address := Bits.of_int_trunc ~width:6 addr;
    inputs.load := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.load := Bits.gnd
  in

  let read addr expected =
    inputs.address := Bits.of_int_trunc ~width:6 addr;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: RAM64[%d] = 0x%04X\n" addr out
    end else begin
      incr failed;
      printf "FAIL: RAM64[%d] = 0x%04X, expected 0x%04X\n" addr out expected
    end
  in

  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  write 0 0x0001;
  write 7 0x0008;
  write 8 0x0010;
  write 15 0x0080;
  write 63 0xFFFF;

  read 0 0x0001;
  read 7 0x0008;
  read 8 0x0010;
  read 15 0x0080;
  read 63 0xFFFF;
  read 32 0x0000;

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
