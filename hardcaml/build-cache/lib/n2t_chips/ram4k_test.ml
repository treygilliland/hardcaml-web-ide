open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Ram4k

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "RAM4K" =
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
    inputs.address := Bits.of_int_trunc ~width:12 addr;
    inputs.load := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.load := Bits.gnd
  in

  let read addr expected =
    inputs.address := Bits.of_int_trunc ~width:12 addr;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: RAM4K[%d] = 0x%04X\n" addr out
    end else begin
      incr failed;
      printf "FAIL: RAM4K[%d] = 0x%04X, expected 0x%04X\n" addr out expected
    end
  in

  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  write 0 0x0001;
  write 512 0x0200;
  write 1024 0x0400;
  write 4095 0xFFFF;

  read 0 0x0001;
  read 512 0x0200;
  read 1024 0x0400;
  read 4095 0xFFFF;
  read 2048 0x0000;

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

