open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Register

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Register" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp load expected =
    inputs.inp := Bits.of_int_trunc ~width:16 inp;
    inputs.load := Bits.of_int_trunc ~width:1 load;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Register(in=0x%04X, load=%d) -> out=0x%04X\n" inp load out
    end else begin
      incr failed;
      printf "FAIL: Register(in=0x%04X, load=%d) -> out=0x%04X, expected 0x%04X\n" inp load out expected
    end
  in

  (* Clear first *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* Load disabled - value stays at 0 *)
  test 0x1234 0 0x0000;
  test 0xABCD 0 0x0000;
  
  (* Load enabled - store value (takes effect immediately) *)
  test 0x1234 1 0x1234;
  test 0xFFFF 0 0x1234;  (* maintains 0x1234 *)
  test 0x0000 0 0x1234;
  
  (* Load new value (takes effect immediately) *)
  test 0xABCD 1 0xABCD;
  test 0x0000 0 0xABCD;
  
  (* Load zero (takes effect immediately) *)
  test 0x0000 1 0x0000;
  test 0xFFFF 0 0x0000;
  
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
