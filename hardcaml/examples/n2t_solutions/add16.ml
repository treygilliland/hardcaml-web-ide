(* 16-bit Adder: Adds two 16-bit values
   
   Hierarchical implementation using a HalfAdder for bit 0 
   and FullAdders for bits 1-15 *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a [@bits 16]
    ; b : 'a [@bits 16]
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
  let sum0, carry0 = halfadder_ scope (List.hd_exn a_bits) (List.hd_exn b_bits) in
  let _, sums = 
    List.fold2_exn 
      (List.tl_exn a_bits) (List.tl_exn b_bits)
      ~init:(carry0, [sum0])
      ~f:(fun (carry, sums) a_bit b_bit ->
        let sum, new_carry = fulladder_ scope a_bit b_bit carry in
        (new_carry, sum :: sums))
  in
  { out = concat_lsb (List.rev sums) }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"add16" create

