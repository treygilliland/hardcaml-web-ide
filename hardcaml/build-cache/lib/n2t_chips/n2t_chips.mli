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

