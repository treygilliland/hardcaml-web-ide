(* ROM32K: 32K read-only memory for instruction storage
   In simulation, this is implemented as a RAM with a disabled write port.
   The ROM can be pre-loaded with program data externally. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; address : 'a [@bits 15]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let mem = Ram.create ~name:"rom32k_mem" ~collision_mode:Write_before_read ~size:32768 ~write_ports:[|
    { write_clock = i.clock
    ; write_address = i.address
    ; write_enable = gnd
    ; write_data = zero 16
    }
  |] ~read_ports:[|
    { read_clock = i.clock
    ; read_address = i.address
    ; read_enable = vdd
    }
  |] ()
  in
  { out = mem.(0) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"rom32k" create
