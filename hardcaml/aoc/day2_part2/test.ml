open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let passed = ref 0
let failed = ref 0

(* Expected answer for the test input. Update this value when using different input. *)
let expected_answer = 4174379265L

(* Parse a range string like "11-22" into (lo, hi) tuple *)
let parse_range (s : string) : int64 * int64 =
  let parts = String.split s ~on:'-' in
  match parts with
  | [lo; hi] -> (Int64.of_string lo, Int64.of_string hi)
  | _ -> failwith ("Invalid range: " ^ s)
;;

(* Parse input - single line with comma-separated ranges *)
let parse_input input_string : (int64 * int64) list =
  String.split_lines input_string
  |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
  |> List.concat_map ~f:(fun line ->
       String.split (String.strip line) ~on:','
       |> List.filter ~f:(fun s -> not (String.is_empty (String.strip s)))
       |> List.map ~f:parse_range)
;;

(* Convert a number to its decimal digits (MSB first), returning digits and count *)
let number_to_digits (n : int64) : int list * int =
  let s = Int64.to_string n in
  let digits = String.to_list s |> List.map ~f:(fun c -> Char.get_digit_exn c) in
  (* Pad to 10 digits with leading zeros *)
  let padded = List.init (10 - List.length digits) ~f:(fun _ -> 0) @ digits in
  (padded, String.length s)
;;

(* Pack digits into a single 40-bit value (10 digits * 4 bits each) *)
let pack_digits (digits : int list) : int =
  List.foldi digits ~init:0 ~f:(fun i acc d ->
    acc lor (d lsl ((9 - i) * 4)))
;;

let input_data = In_channel.read_all "input.txt"

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let ranges = parse_input input_data in
  printf "Processing %d ranges\n" (List.length ranges);
  
  let send_number (n : int64) =
    let (digits, digit_count) = number_to_digits n in
    let packed = pack_digits digits in
    inputs.Circuit.I.digits := Bits.of_int_trunc ~width:40 packed;
    inputs.digit_count := Bits.of_int_trunc ~width:4 digit_count;
    inputs.value := Bits.of_int64_trunc ~width:40 n;
    inputs.number_valid := Bits.vdd;
    cycle ();
    inputs.number_valid := Bits.gnd
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
  
  (* Process all numbers in all ranges *)
  List.iter ranges ~f:(fun (lo, hi) ->
    let rec process n =
      if Int64.(n <= hi) then begin
        send_number n;
        process Int64.(n + 1L)
      end
    in
    process lo);
  
  cycle ();
  
  let sum = Bits.to_int64_trunc !(outputs.Circuit.O.sum) in
  let match_count = Bits.to_int_trunc !(outputs.match_count) in
  
  if Int64.(sum = expected_answer) then begin
    incr passed;
    printf "PASS: sum = %Ld (match_count = %d)\n" sum match_count
  end else begin
    incr failed;
    printf "FAIL: sum = %Ld, expected = %Ld (match_count = %d)\n" sum expected_answer match_count
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

let%expect_test "Day 2 Part 2" =
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
