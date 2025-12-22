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
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  
  (* Count 10 times *)
  inputs.enable := Bits.vdd;
  for _ = 1 to 10 do
    cycle ()
  done;
  
  (* Pause counting *)
  inputs.enable := Bits.gnd;
  cycle ();
  cycle ();
  
  (* Resume counting *)
  inputs.enable := Bits.vdd;
  for _ = 1 to 5 do
    cycle ()
  done;
  
  let final_count = Bits.to_unsigned_int !(outputs.count) in
  print_s [%message "Result" (final_count : int)];
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"
;;

let%expect_test "Counter test" =
  Harness.run_advanced 
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical 
    ~trace:`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;
