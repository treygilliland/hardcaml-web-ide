open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

let test_output outputs name expected actual =
  if actual = expected then begin
    incr passed;
    printf "PASS: %s = %d\n" name actual
  end else begin
    incr failed;
    printf "FAIL: %s = %d, expected %d\n" name actual expected
  end

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  
  (* Test 1: a=5, b=3 *)
  inputs.a := Bits.of_int_trunc ~width:4 5;
  inputs.b := Bits.of_int_trunc ~width:4 3;
  cycle ();
  
  let and_val = Bits.to_unsigned_int !(outputs.Circuit.O.and_out) in
  let or_val = Bits.to_unsigned_int !(outputs.Circuit.O.or_out) in
  let xor_val = Bits.to_unsigned_int !(outputs.Circuit.O.xor_out) in
  let not_a_val = Bits.to_unsigned_int !(outputs.Circuit.O.not_a) in
  let sum_val = Bits.to_unsigned_int !(outputs.Circuit.O.sum) in
  let equal_val = Bits.to_int !(outputs.Circuit.O.equal) in
  
  test_output outputs "and" (5 land 3) and_val;  (* 5 & 3 = 1 *)
  test_output outputs "or" (5 lor 3) or_val;    (* 5 | 3 = 7 *)
  test_output outputs "xor" (5 lxor 3) xor_val;   (* 5 ^ 3 = 6 *)
  test_output outputs "not_a" ((lnot 5) land 0xF) not_a_val;  (* ~5 & 0xF = 10 *)
  test_output outputs "sum" (5 + 3) sum_val;      (* 5 + 3 = 8 *)
  test_output outputs "equal" 0 equal_val;          (* 5 != 3, so equal = 0 *)
  
  (* Test 2: a=7, b=7 (equal) *)
  inputs.a := Bits.of_int_trunc ~width:4 7;
  inputs.b := Bits.of_int_trunc ~width:4 7;
  cycle ();
  
  let equal_val2 = Bits.to_int !(outputs.Circuit.O.equal) in
  test_output outputs "equal" 1 equal_val2;  (* 7 == 7, so equal = 1 *)
  
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  Harness_utils.write_vcd_if_requested waves
;;

let%expect_test "Hello Operators test" =
  passed := 0;
  failed := 0;
  Harness.run_advanced 
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical 
    ~trace:`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;
