open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Ram8

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "RAM8" =
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
    inputs.address := Bits.of_int_trunc ~width:3 addr;
    inputs.load := Bits.vdd;
    Cyclesim.cycle sim;
    inputs.load := Bits.gnd
  in

  let read addr expected =
    inputs.address := Bits.of_int_trunc ~width:3 addr;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: RAM8[%d] = 0x%04X\n" addr out
    end else begin
      incr failed;
      printf "FAIL: RAM8[%d] = 0x%04X, expected 0x%04X\n" addr out expected
    end
  in

  (* Clear first *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* Write different values to each address *)
  write 0 0x0001;
  write 1 0x0002;
  write 2 0x0004;
  write 3 0x0008;
  write 4 0x0010;
  write 5 0x0020;
  write 6 0x0040;
  write 7 0x0080;

  (* Read back all values *)
  read 0 0x0001;
  read 1 0x0002;
  read 2 0x0004;
  read 3 0x0008;
  read 4 0x0010;
  read 5 0x0020;
  read 6 0x0040;
  read 7 0x0080;

  (* Overwrite some values *)
  write 3 0xABCD;
  write 5 0x1234;

  (* Verify overwrites and unchanged values *)
  read 2 0x0004;
  read 3 0xABCD;
  read 4 0x0010;
  read 5 0x1234;
  read 6 0x0040;

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

