open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  
  (* Reset the circuit *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Compute fibonacci(10) = 89 *)
  print_endline "Computing fibonacci(10)...";
  inputs.start := Bits.vdd;
  inputs.n := Bits.of_unsigned_int ~width:8 10;
  cycle ();
  inputs.start := Bits.gnd;
  
  (* Wait for done signal *)
  let max_cycles = 20 in
  let rec wait_done n =
    if n = 0 then failwith "Timeout waiting for done"
    else if Bits.to_bool !(outputs.done_) then ()
    else begin cycle (); wait_done (n - 1) end
  in
  wait_done max_cycles;
  
  let result = Bits.to_unsigned_int !(outputs.result) in
  print_s [%message "Fibonacci result" (result : int)];
  
  (* Verify correctness *)
  if result = 89 then print_endline "PASS: fibonacci(10) = 89"
  else print_endline ("FAIL: expected 89, got " ^ Int.to_string result);
  
  cycle ();
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"
;;

let%expect_test "Fibonacci test" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;

