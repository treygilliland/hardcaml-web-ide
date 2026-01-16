(* Day 12 Part 1 - Advent of Code 2025
   
   Count regions where total shape area fits in the grid.
   Each shape is 9 cells (3x3), so: total_count * 9 <= width * height *)

open! Core
open! Hardcaml
open! Signal

(* # Constants *)

let width_bits = 7      (* Grid width up to 127 *)
let height_bits = 7     (* Grid height up to 127 *)
let count_bits = 10     (* Total count up to 1023 *)
let result_bits = 16    (* Result counter *)

(* # I/O Interface *)

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; problem_valid : 'a
    ; width : 'a [@bits width_bits]
    ; height : 'a [@bits height_bits]
    ; total_count : 'a [@bits count_bits]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { possible_count : 'a [@bits result_bits]
    }
  [@@deriving hardcaml]
end

(* # Circuit Implementation *)

let create scope ({ clock; clear; start; problem_valid; width; height; total_count } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in

  (* Register for counting valid problems *)
  let%hw_var possible_count = Variable.reg spec ~width:result_bits in

  (* Area computation needs enough bits:
     - grid_area = width * height: max 127 * 127 = 16129 (14 bits)
     - shape_area = total_count * 9: max 1023 * 9 = 9207 (14 bits) *)
  let compute_width = 14 in
  
  (* Compute grid area: width * height *)
  let width_ext = uresize ~width:compute_width width in
  let height_ext = uresize ~width:compute_width height in
  let grid_area = width_ext *: height_ext in
  
  (* Compute shape area: total_count * 9 *)
  let count_ext = uresize ~width:compute_width total_count in
  let nine = of_int_trunc ~width:compute_width 9 in
  let shape_area = count_ext *: nine in
  
  (* Check if shapes fit: shape_area <= grid_area *)
  let fits = shape_area <=: grid_area in

  (* State machine logic *)
  compile
    [ when_ start
        [ possible_count <-- zero result_bits
        ]
    ; when_ problem_valid
        [ when_ fits [ possible_count <-- possible_count.value +: one result_bits ]
        ]
    ];

  (* Outputs *)
  { possible_count = possible_count.value }
;;

(* # Hierarchical wrapper *)

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"day12_part1" create
;;

