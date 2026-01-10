(* 16-bit multiplexor: for i = 0..15: if (sel = 0) out[i] = a[i], else out[i] = b[i]
   
   Hierarchical implementation: Apply Mux to each pair of bits. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
    ; sel : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 16] } [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let a_bits = bits_lsb i.a in
  let b_bits = bits_lsb i.b in
  let muxed = List.map2_exn a_bits b_bits ~f:(fun a b -> mux_ scope a b i.sel) in
  { out = concat_lsb muxed }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"mux16" create
