(** Nand2Tetris Chip Library for Hardcaml
    
    Reference implementations of the Hack chipset. Import chips as [N2t_chips.Not],
    [N2t_chips.And], etc. Use helper functions for concise instantiation. *)

open! Hardcaml

module Nand = Nand
module Not = Not
module And = And
module Or = Or
module Xor = Xor
module Mux = Mux
module Dmux = Dmux
module Not16 = Not16
module And16 = And16
module Or16 = Or16
module Mux16 = Mux16
module Or8way = Or8way
module Mux4way16 = Mux4way16
module Mux8way16 = Mux8way16
module Dmux4way = Dmux4way
module Dmux8way = Dmux8way

(** {1 Helper Functions}
    
    Convenience functions for concise chip instantiation in hierarchical designs.
    Usage: [let open N2t_chips in not_ scope sel] *)

val nand_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val not_ : Scope.t -> Signal.t -> Signal.t
val and_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val or_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val xor_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val mux_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val dmux_ : Scope.t -> Signal.t -> Signal.t -> Signal.t * Signal.t

val not16_ : Scope.t -> Signal.t -> Signal.t
val and16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val or16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val mux16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val or8way_ : Scope.t -> Signal.t -> Signal.t
val mux4way16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val mux8way16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val dmux4way_ : Scope.t -> Signal.t -> Signal.t -> Signal.t * Signal.t * Signal.t * Signal.t
val dmux8way_ : Scope.t -> Signal.t -> Signal.t -> Signal.t * Signal.t * Signal.t * Signal.t * Signal.t * Signal.t * Signal.t * Signal.t
