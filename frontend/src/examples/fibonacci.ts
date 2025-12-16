import type { HardcamlExample } from "./examples";

/**
 * Fibonacci State Machine Example
 *
 * A state machine that computes the n-th Fibonacci number.
 * This example demonstrates:
 * - State machines with Always.State_machine
 * - Multiple register variables
 * - Combining wire and register outputs
 * - Sequential computation over multiple cycles
 */
export const fibonacciExample: HardcamlExample = {
  name: "Fibonacci",
  description:
    "A state machine that computes the n-th Fibonacci number over multiple clock cycles",
  difficulty: "intermediate",
  category: "hardcaml",

  circuit: `open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; n : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { done_ : 'a [@rtlname "done"]
    ; result : 'a [@bits 32]
    ; state : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module States = struct
  type t =
    | S_wait
    | S_counting
    | S_write_result
  [@@deriving sexp_of, compare ~localize, enumerate]
end

let create scope (i : _ I.t) =
  let _ = scope in
  let r_sync = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let sm = Always.State_machine.create (module States) ~enable:vdd r_sync in
  let done_ = Always.Variable.wire ~default:gnd () in
  let result = Always.Variable.wire ~default:(zero 32) () in
  let f0 = Always.Variable.reg ~width:32 ~enable:vdd r_sync in
  let f1 = Always.Variable.reg ~width:32 ~enable:vdd r_sync in
  let remaining = Always.Variable.reg ~width:8 ~enable:vdd r_sync in
  Always.(
    compile
      [ sm.switch
          [ ( S_wait
            , [ f0 <--. 1
              ; f1 <--. 1
              ; remaining <-- i.n -:. 1
              ; when_
                  i.start
                  [ if_
                      (i.n ==:. 0)
                      [ sm.set_next S_write_result ]
                      [ sm.set_next S_counting ]
                  ]
              ] )
          ; ( S_counting
            , [ if_
                  (remaining.value ==:. 0)
                  [ sm.set_next S_write_result ]
                  [ remaining <-- remaining.value -:. 1
                  ; f0 <-- f1.value
                  ; f1 <-- f0.value +: f1.value
                  ]
              ] )
          ; S_write_result, [ done_ <--. 1; result <-- f1.value; sm.set_next S_wait ]
          ]
      ]);
  { O.done_ = done_.value
  ; result = result.value
  ; state = sm.current
  }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"fibonacci" create
;;`,

  interface: `open! Core
open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; n : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { done_ : 'a
    ; result : 'a
    ; state : 'a
    }
  [@@deriving hardcaml]
end

module States : sig
  type t =
    | S_wait
    | S_counting
    | S_write_result
  [@@deriving sexp_of, compare ~localize, enumerate]
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
  
  (* Reset the circuit *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;
  cycle ();
  
  (* Compute fibonacci(10) = 89 *)
  print_endline "Computing fibonacci(10)...";
  inputs.start := Bits.vdd;
  inputs.n := Bits.of_unsigned_int ~width:8 10;
  cycle ();
  inputs.start := Bits.gnd;
  
  (* Wait for done signal *)
  let max_cycles = 20 in
  let rec wait_done n =
    if n = 0 then failwith "Timeout waiting for done"
    else if Bits.to_bool !(outputs.done_) then ()
    else begin cycle (); wait_done (n - 1) end
  in
  wait_done max_cycles;
  
  let result = Bits.to_unsigned_int !(outputs.result) in
  print_s [%message "Fibonacci result" (result : int)];
  
  (* Verify correctness *)
  if result = 89 then print_endline "PASS: fibonacci(10) = 89"
  else print_endline ("FAIL: expected 89, got " ^ Int.to_string result);
  
  cycle ();
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  (* Save VCD to file for the backend to read *)
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"
;;

let%expect_test "Fibonacci test" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:\`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;`,
};

