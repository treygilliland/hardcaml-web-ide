open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Parse a line of digits into a list of ints *)
let parse_line (s : string) : int list =
  let s = String.strip s in
  String.to_list s
  |> List.map ~f:(fun c -> Char.get_digit_exn c)
;;

(* Parse all lines from input *)
let parse_input input_string =
  String.split_lines input_string
  |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
  |> List.map ~f:parse_line
;;

(* Compute expected result using the Python algorithm *)
let compute_line_result (nums : int list) : Int64.t =
  let len = List.length nums in
  if len < 12 then 0L
  else
    let nums_arr = Array.of_list nums in
    let rec find_digits i n acc =
      if n < 0 then acc
      else
        (* Search from i+1 to len-n-1 *)
        let start_idx = i + 1 in
        let end_idx = len - n in
        let subset = Array.sub nums_arr ~pos:start_idx ~len:(end_idx - start_idx) in
        let x = Array.fold subset ~init:0 ~f:Int.max in
        let x_idx = 
          match Array.findi subset ~f:(fun _ v -> v = x) with
          | Some (idx, _) -> start_idx + idx
          | None -> start_idx
        in
        let power = Int64.of_float (Float.int_pow 10.0 n) in
        let contribution = Int64.(of_int x * power) in
        find_digits x_idx (n - 1) Int64.(acc + contribution)
    in
    find_digits (-1) 11 0L
;;

let compute_expected (lines : int list list) : Int64.t =
  List.fold lines ~init:0L ~f:(fun acc nums ->
    Int64.(acc + compute_line_result nums)
  )
;;

let input_data = {|INPUT_DATA|}

let ( <--. ) = Bits.( <--. )

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let lines = parse_input input_data in
  let expected = compute_expected lines in
  printf "Processing %d lines\n" (List.length lines);
  printf "Expected result: %Ld\n" expected;
  
  (* Helper to send a single digit *)
  let send_digit d =
    inputs.digit <--. d;
    inputs.digit_valid := Bits.vdd;
    cycle ();
    inputs.digit_valid := Bits.gnd
  in
  
  (* Helper to signal end of line *)
  let send_end_of_line () =
    inputs.end_of_line := Bits.vdd;
    cycle ();
    inputs.end_of_line := Bits.gnd;
    (* Wait for computation to complete - need cycles for 12 max-finds *)
    (* Each find scans up to ~90 positions, so 12 * 90 = 1080 cycles needed *)
    cycle ~n:1500 ()
  in
  
  (* Reset *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Start *)
  inputs.start := Bits.vdd;
  cycle ();
  inputs.start := Bits.gnd;
  cycle ();
  
  (* Process each line *)
  List.iter lines ~f:(fun digits ->
    (* Send each digit *)
    List.iter digits ~f:send_digit;
    (* Signal end of line and wait for processing *)
    send_end_of_line ()
  );
  
  (* Allow final result to settle *)
  cycle ~n:2 ();
  
  let result = Bits.to_int64_trunc !(outputs.result) in
  printf "Circuit result: %Ld\n" result;
  
  if Int64.(result = expected) then begin
    incr passed;
    printf "PASS: result = %Ld\n" result
  end else begin
    incr failed;
    printf "FAIL: result = %Ld, expected = %Ld\n" result expected
  end;

  cycle ~n:2 ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  Harness_utils.write_vcd_if_requested waves
;;

let%expect_test "Day 3 Part 2" =
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
