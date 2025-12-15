(* Test for Day 1 Part 1 *)

open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let ( <--. ) = Bits.( <--. )

(* Test commands: L68, L30, R48, L5, R60, L55, L1, L99, R14, L82 *)
let test_commands = 
  [ (false, 68); (false, 30); (true, 48); (false, 5); (true, 60)
  ; (false, 55); (false, 1); (false, 99); (true, 14); (false, 82) ]

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  
  let send_command (direction, value) =
    inputs.direction := if direction then Bits.vdd else Bits.gnd;
    inputs.value <--. value;
    inputs.command_valid := Bits.vdd;
    cycle ();
    inputs.command_valid := Bits.gnd;
    cycle ()
  in
  
  (* Initialize *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* Run commands *)
  List.iter test_commands ~f:send_command;
  
  let zero_count = Bits.to_unsigned_int !(outputs.zero_count) in
  let final_position = Bits.to_unsigned_int !(outputs.position) in
  print_s [%message "Result" (zero_count : int) (final_position : int)];
  cycle ()
;;

let display_rules =
  [ Display_rule.port_name_matches
      ~wave_format:(Bit_or Unsigned_int)
      (Re.Glob.glob "day1_part1*" |> Re.compile)
  ]
;;

let%expect_test "Day 1 Part 1 - test" =
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
    (Result (zero_count 3) (final_position 32))
    |}]
;;
