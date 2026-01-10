open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Memory

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Memory" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let set_inputs ~inp ~load ~address ~key =
    inputs.inp := Bits.of_int_trunc ~width:16 inp;
    inputs.load := Bits.of_int_trunc ~width:1 load;
    inputs.address := Bits.of_int_trunc ~width:15 address;
    inputs.key := Bits.of_int_trunc ~width:16 key
  in

  let test_cycle ~inp ~load ~address ~key ~expected ~desc =
    set_inputs ~inp ~load ~address ~key;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: %s -> 0x%04X\n" desc out
    end else begin
      incr failed;
      printf "FAIL: %s -> 0x%04X, expected 0x%04X\n" desc out expected
    end
  in

  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  test_cycle ~inp:0x1234 ~load:1 ~address:0x0000 ~key:0 ~expected:0x1234 ~desc:"Write RAM[0]";
  test_cycle ~inp:0x5678 ~load:1 ~address:0x0001 ~key:0 ~expected:0x5678 ~desc:"Write RAM[1]";
  test_cycle ~inp:0x0000 ~load:0 ~address:0x0000 ~key:0 ~expected:0x1234 ~desc:"Read RAM[0]";
  test_cycle ~inp:0x0000 ~load:0 ~address:0x0001 ~key:0 ~expected:0x5678 ~desc:"Read RAM[1]";
  test_cycle ~inp:0xABCD ~load:1 ~address:0x4000 ~key:0 ~expected:0xABCD ~desc:"Write Screen[0]";
  test_cycle ~inp:0x0000 ~load:0 ~address:0x4000 ~key:0 ~expected:0xABCD ~desc:"Read Screen[0]";
  test_cycle ~inp:0x0000 ~load:0 ~address:0x6000 ~key:0x0041 ~expected:0x0041 ~desc:"Read Keyboard (A)";
  test_cycle ~inp:0x0000 ~load:0 ~address:0x6000 ~key:0x0000 ~expected:0x0000 ~desc:"Read Keyboard (none)";

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
