open! Core
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

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t

