import type { HardcamlExample } from './index';

/**
 * Simple Counter Example
 * 
 * A basic 8-bit counter that increments when enabled.
 * This is a good starting point for learning HardCaml's:
 * - Module interface pattern (I/O records)
 * - Register specifications
 * - Always DSL for sequential logic
 * - Hierarchical design patterns
 */
export const counterExample: HardcamlExample = {
  name: 'Simple Counter',
  description: 'An 8-bit counter that increments on each clock cycle when enabled',
  difficulty: 'beginner',
  
  circuit: `open! Core
open! Hardcaml
open! Signal

let counter_bits = 8

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; enable : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { count : 'a [@bits counter_bits]
    }
  [@@deriving hardcaml]
end

let create scope ({ clock; clear; enable } : _ I.t) : _ O.t =
  let _ = scope in
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in
  let%hw_var count = Variable.reg spec ~width:counter_bits in
  compile [ when_ enable [ count <-- count.value +: one counter_bits ] ];
  { count = count.value }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"counter" create
;;`,

  interface: `open! Core
open! Hardcaml

val counter_bits : int

module I : sig
  type 'a t = { clock : 'a; clear : 'a; enable : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { count : 'a }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t`,

  test: `open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  inputs.enable := Bits.vdd;
  for _ = 1 to 10 do cycle () done;
  let final_count = Bits.to_unsigned_int !(outputs.count) in
  print_s [%message "Result" (final_count : int)];
  cycle ()
;;

let%expect_test "Counter test" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:\`All_named
    ~print_waves_after_test:(fun waves ->
      print_endline "===WAVEFORM_START===";
      Waveform.print ~display_width:100 ~wave_width:2 waves;
      print_endline "===WAVEFORM_END===")
    run_testbench;
  [%expect {| |}]
;;`,
};

