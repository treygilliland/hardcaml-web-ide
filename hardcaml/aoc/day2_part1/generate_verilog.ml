(* Generate Verilog from Day 2 Part 1 circuit *)

open! Core
open! Hardcaml
module Circuit = User_circuit.Circuit

let () =
  let scope = Scope.create () in
  (* Use create directly to get flat circuit without hierarchical wrapper *)
  let module C = Hardcaml.Circuit.With_interface (Circuit.I) (Circuit.O) in
  let circuit = C.create_exn ~name:"day2_part1" (Circuit.create scope) in
  let output_file = "day2_part1.v" in
  let verilog_string = 
    let circuits = Hardcaml.Rtl.create Verilog [ circuit ] in
    Hardcaml.Rtl.full_hierarchy circuits |> Rope.to_string
  in
  Out_channel.write_all output_file ~data:verilog_string;
  printf "Generated Verilog: %s\n" output_file
