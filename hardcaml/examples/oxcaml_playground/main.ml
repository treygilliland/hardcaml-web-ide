(* Oxcaml Playground
 * 
 * Feel free to test out any OCaml code you want here!
 * This is a simple OCaml playground where you can experiment with
 * OCaml features, data structures, algorithms, and more.
 * 
 * Just write your code below and run it!
 *)

open! Core

(* Example: Simple list operations *)
let numbers = [1; 2; 3; 4; 5]

let doubled = List.map numbers ~f:(fun x -> x * 2)

let sum = List.fold numbers ~init:0 ~f:(+)

let () =
  printf "Numbers: %s\n" (String.concat ~sep:", " (List.map numbers ~f:Int.to_string));
  printf "Doubled: %s\n" (String.concat ~sep:", " (List.map doubled ~f:Int.to_string));
  printf "Sum: %d\n" sum
