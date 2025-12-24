open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Pc

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "PC" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let set_inputs ~inp ~load ~inc ~reset =
    inputs.inp := Bits.of_int_trunc ~width:16 inp;
    inputs.load := Bits.of_int_trunc ~width:1 load;
    inputs.inc := Bits.of_int_trunc ~width:1 inc;
    inputs.reset := Bits.of_int_trunc ~width:1 reset
  in

  let test_cycle ~inp ~load ~inc ~reset ~expected =
    set_inputs ~inp ~load ~inc ~reset;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    if out = expected then begin
      incr passed;
      printf "PASS: PC(in=0x%04X, load=%d, inc=%d, reset=%d) -> 0x%04X\n" inp load inc reset out
    end else begin
      incr failed;
      printf "FAIL: PC(in=0x%04X, load=%d, inc=%d, reset=%d) -> 0x%04X, expected 0x%04X\n" 
        inp load inc reset out expected
    end
  in

  (* Clear first *)
  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* Do nothing - maintain 0 *)
  test_cycle ~inp:0x1234 ~load:0 ~inc:0 ~reset:0 ~expected:0x0000;
  test_cycle ~inp:0x1234 ~load:0 ~inc:0 ~reset:0 ~expected:0x0000;

  (* Increment - output updates immediately *)
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0001;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0002;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0003;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0004;

  (* Load overrides inc - load takes effect immediately *)
  test_cycle ~inp:0x0100 ~load:1 ~inc:1 ~reset:0 ~expected:0x0100;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0101;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0102;

  (* Reset overrides everything - takes effect immediately *)
  test_cycle ~inp:0xFFFF ~load:1 ~inc:1 ~reset:1 ~expected:0x0000;
  test_cycle ~inp:0x0000 ~load:0 ~inc:0 ~reset:0 ~expected:0x0000;

  (* Load a value and increment *)
  test_cycle ~inp:0xFFFE ~load:1 ~inc:0 ~reset:0 ~expected:0xFFFE;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0xFFFF;
  test_cycle ~inp:0x0000 ~load:0 ~inc:1 ~reset:0 ~expected:0x0000;  (* overflow wraps *)

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

