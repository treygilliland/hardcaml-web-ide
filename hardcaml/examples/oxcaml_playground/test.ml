(* Test file for Oxcaml Playground - just runs main.ml *)
open! Core

(* Import the main module - the code in main.ml will execute when the module is loaded *)
module Main = User_circuit.Main

let passed = ref 0
let failed = ref 0

let%expect_test "Run main.ml" =
  (* The main.ml code executes when User_circuit.Main is loaded above *)
  (* If you want to test specific functions, you can call them here *)
  printf "===TEST_SUMMARY===\n";
  printf "TESTS: %d passed, %d failed\n" !passed !failed;
  [%expect {| |}]
;;
