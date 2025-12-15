(* Placeholder test - will be replaced by user code *)

open! Core
open! Hardcaml

let%expect_test "placeholder" =
  print_endline "Placeholder test";
  [%expect {| Placeholder test |}]
;;
