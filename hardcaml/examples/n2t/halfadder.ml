(* Half Adder: Computes the sum of two bits
   sum = LSB of a + b (i.e., a XOR b)
   carry = MSB of a + b (i.e., a AND b)
   
   Implement using N2t_chips gates. *)

open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { a : 'a
    ; b : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { sum : 'a
    ; carry : 'a
    }
  [@@deriving hardcaml]
end

let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips gates *)
  { sum = gnd; carry = gnd }

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"halfadder" create

