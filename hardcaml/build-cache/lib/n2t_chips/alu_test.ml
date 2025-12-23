open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Alu

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"

let%expect_test "ALU" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let test x y zx nx zy ny f no expected_out expected_zr expected_ng desc =
    inputs.x := Bits.of_int_trunc ~width:16 x;
    inputs.y := Bits.of_int_trunc ~width:16 y;
    inputs.zx := Bits.of_int_trunc ~width:1 zx;
    inputs.nx := Bits.of_int_trunc ~width:1 nx;
    inputs.zy := Bits.of_int_trunc ~width:1 zy;
    inputs.ny := Bits.of_int_trunc ~width:1 ny;
    inputs.f := Bits.of_int_trunc ~width:1 f;
    inputs.no := Bits.of_int_trunc ~width:1 no;
    Cyclesim.cycle sim;
    let out = Bits.to_int_trunc !(outputs.out) in
    let zr = Bits.to_int_trunc !(outputs.zr) in
    let ng = Bits.to_int_trunc !(outputs.ng) in
    if out = expected_out && zr = expected_zr && ng = expected_ng then begin
      incr passed;
      printf "PASS: %s = 0x%04X (zr=%d, ng=%d)\n" desc out zr ng
    end else begin
      incr failed;
      printf "FAIL: %s = 0x%04X (zr=%d, ng=%d), expected 0x%04X (zr=%d, ng=%d)\n" 
        desc out zr ng expected_out expected_zr expected_ng
    end
  in

  (* Test basic ALU operations with x=0x0005, y=0x0003 *)
  let x = 0x0005 in
  let y = 0x0003 in

  (* 0: out = 0 *)
  test x y 1 0 1 0 1 0 0x0000 1 0 "0";
  (* 1: out = 1 *)
  test x y 1 1 1 1 1 1 0x0001 0 0 "1";
  (* -1: out = -1 = 0xFFFF *)
  test x y 1 1 1 0 1 0 0xFFFF 0 1 "-1";
  (* x: out = x *)
  test x y 0 0 1 1 0 0 x 0 0 "x";
  (* y: out = y *)
  test x y 1 1 0 0 0 0 y 0 0 "y";
  (* !x: out = ~x *)
  test x y 0 0 1 1 0 1 (0xFFFF land (lnot x)) 0 1 "!x";
  (* !y: out = ~y *)
  test x y 1 1 0 0 0 1 (0xFFFF land (lnot y)) 0 1 "!y";
  (* -x: out = -x (two's complement) *)
  test x y 0 0 1 1 1 1 (0xFFFF land (-x)) 0 1 "-x";
  (* -y: out = -y *)
  test x y 1 1 0 0 1 1 (0xFFFF land (-y)) 0 1 "-y";
  (* x+1 *)
  test x y 0 1 1 1 1 1 (x + 1) 0 0 "x+1";
  (* y+1 *)
  test x y 1 1 0 1 1 1 (y + 1) 0 0 "y+1";
  (* x-1 *)
  test x y 0 0 1 1 1 0 (x - 1) 0 0 "x-1";
  (* y-1 *)
  test x y 1 1 0 0 1 0 (y - 1) 0 0 "y-1";
  (* x+y *)
  test x y 0 0 0 0 1 0 (x + y) 0 0 "x+y";
  (* x-y *)
  test x y 0 1 0 0 1 1 (0xFFFF land (x - y)) 0 0 "x-y";
  (* y-x *)
  test x y 0 0 0 1 1 1 (0xFFFF land (y - x)) 0 1 "y-x";
  (* x&y *)
  test x y 0 0 0 0 0 0 (x land y) 0 0 "x&y";
  (* x|y *)
  test x y 0 1 0 1 0 1 (x lor y) 0 0 "x|y";

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]

