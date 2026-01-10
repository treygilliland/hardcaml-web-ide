open! Core
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
;;
