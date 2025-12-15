(* Test for simple counter *)

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

let display_rules =
  [ Display_rule.port_name_matches
      ~wave_format:(Bit_or Unsigned_int)
      (Re.Glob.glob "counter*" |> Re.compile)
  ]
;;

let%expect_test "Counter test" =
  Harness.run_advanced 
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical 
    ~trace:`All_named
    ~print_waves_after_test:(fun waves ->
      Waveform.print
        ~display_rules
        ~signals_width:35
        ~display_width:120
        ~wave_width:2
        waves)
    run_testbench;
  [%expect {|
    (Result (final_count 15))
    |}]
;;
