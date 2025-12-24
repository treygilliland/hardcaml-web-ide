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
module Halfadder = Halfadder
module Fulladder = Fulladder
module Add16 = Add16
module Inc16 = Inc16
module Alu = Alu
module Dff = Dff
module Bit = Bit
module Register = Register
module Ram8 = Ram8
module Pc = Pc
module Ram64 = Ram64
module Ram512 = Ram512
module Ram4k = Ram4k
module Ram16k = Ram16k
module Screen = Screen
module Keyboard = Keyboard
module Aregister = Aregister
module Dregister = Dregister
module Rom32k = Rom32k
module Memory = Memory
module Cpu = Cpu
module Computer = Computer

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

val halfadder_ : Scope.t -> Signal.t -> Signal.t -> Signal.t * Signal.t
val fulladder_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t * Signal.t
val add16_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val inc16_ : Scope.t -> Signal.t -> Signal.t
val alu_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t * Signal.t * Signal.t

val dff_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val bit_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val register_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val ram8_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val pc_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val ram64_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val ram512_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val ram4k_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val ram16k_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val screen_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val keyboard_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val aregister_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val dregister_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val rom32k_ : Scope.t -> Signal.t -> Signal.t -> Signal.t
val memory_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t
val cpu_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t * Signal.t * Signal.t * Signal.t
val computer_ : Scope.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t -> Signal.t * Signal.t * Signal.t * Signal.t
