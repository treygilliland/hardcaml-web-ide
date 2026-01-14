open! Core
open! Hardcaml
open! Hardcaml_waveterm
module Circuit = User_circuit.Cpu

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:80 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Harness_utils.write_vcd_if_requested waves

let%expect_test "CPU" =
  let module Sim = Cyclesim.With_interface (Circuit.I) (Circuit.O) in
  let scope = Scope.create ~flatten_design:true () in
  let sim = Sim.create ~config:Cyclesim.Config.trace_all (Circuit.create scope) in
  let waves, sim = Waveform.create sim in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  let passed = ref 0 in
  let failed = ref 0 in

  let set_inputs ~inM ~instruction ~reset =
    inputs.inM := Bits.of_int_trunc ~width:16 inM;
    inputs.instruction := Bits.of_int_trunc ~width:16 instruction;
    inputs.reset := Bits.of_int_trunc ~width:1 reset
  in

  let test_cycle ~inM ~instruction ~reset ~expected_writeM ~expected_addressM ~expected_pc ~desc =
    set_inputs ~inM ~instruction ~reset;
    Cyclesim.cycle sim;
    let writeM = Bits.to_int_trunc !(outputs.writeM) in
    let addressM = Bits.to_int_trunc !(outputs.addressM) in
    let pc = Bits.to_int_trunc !(outputs.pc) in
    let pass = writeM = expected_writeM && addressM = expected_addressM && pc = expected_pc in
    if pass then begin
      incr passed;
      printf "PASS: %s (addressM=%d, pc=%d)\n" desc addressM pc
    end else begin
      incr failed;
      printf "FAIL: %s\n" desc;
      printf "  writeM=%d (expected %d), addressM=%d (expected %d), pc=%d (expected %d)\n" 
        writeM expected_writeM addressM expected_addressM pc expected_pc
    end
  in

  let test_c_instruction ~inM ~instruction ~reset ~expected_outM ~expected_writeM ~expected_addressM ~expected_pc ~desc =
    set_inputs ~inM ~instruction ~reset;
    Cyclesim.cycle sim;
    let outM = Bits.to_int_trunc !(outputs.outM) in
    let writeM = Bits.to_int_trunc !(outputs.writeM) in
    let addressM = Bits.to_int_trunc !(outputs.addressM) in
    let pc = Bits.to_int_trunc !(outputs.pc) in
    let pass = outM = expected_outM && writeM = expected_writeM && 
               addressM = expected_addressM && pc = expected_pc in
    if pass then begin
      incr passed;
      printf "PASS: %s (outM=%d, addressM=%d, pc=%d)\n" desc outM addressM pc
    end else begin
      incr failed;
      printf "FAIL: %s\n" desc;
      printf "  outM=%d (expected %d), writeM=%d (expected %d)\n" outM expected_outM writeM expected_writeM;
      printf "  addressM=%d (expected %d), pc=%d (expected %d)\n" addressM expected_addressM pc expected_pc
    end
  in

  inputs.clear := Bits.vdd;
  Cyclesim.cycle sim;
  inputs.clear := Bits.gnd;

  (* A-instruction: @21 (load 21 into A) *)
  (* For A-instructions, outM is undefined (garbage ALU control bits) *)
  test_cycle ~inM:0 ~instruction:21 ~reset:0 
    ~expected_writeM:0 ~expected_addressM:21 ~expected_pc:1 
    ~desc:"@21 (A-instruction)";

  (* C-instruction: D=A (compute A, store in D) *)
  (* 1110110000010000 = 0xEC10: zx=1,nx=1 gives x=-1, AND with y=A gives A *)
  test_c_instruction ~inM:0 ~instruction:0xEC10 ~reset:0 
    ~expected_outM:21 ~expected_writeM:0 ~expected_addressM:21 ~expected_pc:2 
    ~desc:"D=A";

  (* A-instruction: @100 *)
  test_cycle ~inM:0 ~instruction:100 ~reset:0 
    ~expected_writeM:0 ~expected_addressM:100 ~expected_pc:3 
    ~desc:"@100";

  (* C-instruction: D=A again (0xEC10) to verify D=21 and A=100 *)
  (* Note: After cycle, ALU recomputes with NEW register values, so we test D=A 
     which outputs A regardless of D's new value *)
  test_c_instruction ~inM:0 ~instruction:0xEC10 ~reset:0 
    ~expected_outM:100 ~expected_writeM:0 ~expected_addressM:100 ~expected_pc:4 
    ~desc:"D=A (should output A=100)";

  (* Reset *)
  test_cycle ~inM:0 ~instruction:0 ~reset:1 
    ~expected_writeM:0 ~expected_addressM:0 ~expected_pc:0 
    ~desc:"Reset";

  (* After reset, run @42 to verify PC works *)
  test_cycle ~inM:0 ~instruction:42 ~reset:0 
    ~expected_writeM:0 ~expected_addressM:42 ~expected_pc:1 
    ~desc:"@42 after reset";

  print_waves_and_save_vcd waves;
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
