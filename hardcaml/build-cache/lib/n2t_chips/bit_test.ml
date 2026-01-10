open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Bit

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "Bit register" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test inp load expected =
    inputs.inp := Bits.of_int_trunc ~width:1 inp;
    inputs.load := Bits.of_int_trunc ~width:1 load;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: Bit(in=%d, load=%d) -> out=%d\n" inp load out
    end else begin
      incr failed;
      printf "FAIL: Bit(in=%d, load=%d) -> out=%d, expected %d\n" inp load out expected
    end
  in

  (* Clear first *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* Load disabled - value stays at 0 *)
  test 1 0 0;  (* in=1 but load=0, so output stays 0 *)
  test 1 0 0;  (* still no load *)
  
  (* Load enabled - store 1 (takes effect immediately) *)
  test 1 1 1;  (* in=1, load=1, output is 1 *)
  test 0 0 1;  (* in=0, load=0, output shows stored 1 *)
  test 0 0 1;  (* value maintained *)
  
  (* Load new value 0 (takes effect immediately) *)
  test 0 1 0;  (* in=0, load=1, output is 0 *)
  test 1 0 0;  (* in=1, load=0, output shows stored 0 *)
  
  (* Toggle *)
  test 1 1 1;  (* load 1 *)
  test 0 1 0;  (* load 0 *)
  test 0 0 0;  (* maintain *)
  
  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
