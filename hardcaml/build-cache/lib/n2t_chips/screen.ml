(* Screen: 8K memory-mapped display (13-bit address, 16-bit data)
   Behaves like RAM8K - reads and writes to screen memory *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16] [@rtlname "in"]
    ; load : 'a
    ; address : 'a [@bits 13]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let mem = Ram.create ~name:"screen_mem" ~collision_mode:Read_before_write ~size:8192 ~write_ports:[|
    { write_clock = i.clock
    ; write_address = i.address
    ; write_enable = i.load
    ; write_data = i.inp
    }
  |] ~read_ports:[|
    { read_clock = i.clock
    ; read_address = i.address
    ; read_enable = vdd
    }
  |] ()
  in
  let _ = spec in
  let _ = scope in
  { out = mem.(0) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"screen" create

