# Nand2Tetris Implementation

This document describes how we implement the Nand2Tetris (N2T) chipset in the Hardcaml Web IDE.

## Architecture

We have **three distinct implementations** of each chip, each serving a different purpose:

### 1. Library Chips (`hardcaml/build-cache/lib/n2t_chips/`)

Efficient reference implementations using Hardcaml's native primitives. These are:

- Compiled into the `n2t_chips` library
- Importable by user code as `N2t_chips.Not`, `N2t_chips.And`, etc.
- Not exposed directly to users for implementation details
- Used internally by the hierarchical reference solutions

```ocaml
(* Example: lib/n2t_chips/not.ml - uses native Hardcaml *)
let create _scope (i : _ I.t) : _ O.t =
  { out = ~:(i.a) }
```

### 2. Student Stubs (`hardcaml/examples/n2t/`)

Placeholder files for students to complete. These:

- Provide the interface (I/O modules) and test harness
- Return `gnd` as a default (allows tests to run and show failures)
- Include hints in comments about how to implement
- Are loaded into the editor when selecting "Nand2Tetris" exercises

```ocaml
(* Example: examples/n2t/not.ml - student fills this in *)
let create _scope (_i : _ I.t) : _ O.t =
  (* TODO: implement using N2t_chips.Nand.nand *)
  { out = gnd }
```

### 3. Reference Solutions (`hardcaml/examples/n2t_solutions/`)

Canonical hierarchical implementations that demonstrate the N2T approach:

- Build chips from previously-defined chips (AND uses NOT, OR uses NOT, etc.)
- Use `N2t_chips` helper functions for concise syntax
- Shown when selecting "Nand2Tetris Solutions" in the dropdown

```ocaml
(* Example: examples/n2t_solutions/or.ml - hierarchical construction *)
let create scope (i : _ I.t) : _ O.t =
  let open N2t_chips in
  let not_a = not_ scope i.a in
  let not_b = not_ scope i.b in
  { out = Nand.nand not_a not_b }
```

## Helper Functions

The `N2t_chips` library provides helper functions for concise chip instantiation:

```ocaml
(* Without helpers - verbose *)
let not_a = (N2t_chips.Not.create scope { N2t_chips.Not.I.a = i.a }).out

(* With helpers - concise *)
let not_a = N2t_chips.not_ scope i.a
```

All helpers take a `scope` parameter to preserve hierarchy in waveforms. Available helpers:

| Function     | Signature                                                             |
| ------------ | --------------------------------------------------------------------- |
| `nand_`      | `scope -> a -> b -> out`                                              |
| `not_`       | `scope -> a -> out`                                                   |
| `and_`       | `scope -> a -> b -> out`                                              |
| `or_`        | `scope -> a -> b -> out`                                              |
| `xor_`       | `scope -> a -> b -> out`                                              |
| `mux_`       | `scope -> a -> b -> sel -> out`                                       |
| `dmux_`      | `scope -> inp -> sel -> (a, b)`                                       |
| `not16_`     | `scope -> a -> out`                                                   |
| `and16_`     | `scope -> a -> b -> out`                                              |
| `or16_`      | `scope -> a -> b -> out`                                              |
| `mux16_`     | `scope -> a -> b -> sel -> out`                                       |
| `or8way_`    | `scope -> a -> out`                                                   |
| `mux4way16_` | `scope -> a -> b -> c -> d -> sel -> out`                             |
| `mux8way16_` | `scope -> a -> b -> c -> d -> e -> f -> g -> h -> sel -> out`         |
| `dmux4way_`  | `scope -> inp -> sel -> (a, b, c, d)`                                 |
| `dmux8way_`  | `scope -> inp -> sel -> (a, b, c, d, e, f, g, h)`                     |
| `halfadder_` | `scope -> a -> b -> (sum, carry)`                                     |
| `fulladder_` | `scope -> a -> b -> c -> (sum, carry)`                                |
| `add16_`     | `scope -> a -> b -> out`                                              |
| `inc16_`     | `scope -> inp -> out`                                                 |
| `alu_`       | `scope -> x -> y -> zx -> nx -> zy -> ny -> f -> no -> (out, zr, ng)` |
| `dff_`       | `scope -> clock -> clear -> inp -> out`                               |
| `bit_`       | `scope -> clock -> clear -> inp -> load -> out`                       |
| `register_`  | `scope -> clock -> clear -> inp -> load -> out`                       |
| `ram8_`      | `scope -> clock -> clear -> inp -> load -> address -> out`            |
| `pc_`        | `scope -> clock -> clear -> inp -> load -> inc -> reset -> out`       |
| `ram64_`     | `scope -> clock -> clear -> inp -> load -> address -> out`            |
| `ram512_`    | `scope -> clock -> clear -> inp -> load -> address -> out`            |
| `ram4k_`     | `scope -> clock -> clear -> inp -> load -> address -> out`            |
| `ram16k_`    | `scope -> clock -> clear -> inp -> load -> address -> out`            |

## Mux Convention

**Important:** The N2T and Hardcaml mux conventions differ:

| Convention                   | sel=0     | sel=1      |
| ---------------------------- | --------- | ---------- |
| N2T                          | out = a   | out = b    |
| Hardcaml `mux2 sel high low` | out = low | out = high |

### In Library Implementations (using `mux2` directly)

When using Hardcaml's `mux2` directly, swap the arguments:

```ocaml
(* N2T: Mux16(a=x, b=zero, sel=zx) -> if zx=0 then x, if zx=1 then zero *)
(* Hardcaml: mux2 sel high low -> mux2 zx zero x *)
let x1 = mux2 i.zx (zero 16) i.x in
```

### In Solutions (using `mux16_` helper)

The `mux16_` helper follows N2T convention, so use natural argument order:

```ocaml
(* N2T: Mux16(a=x, b=zero, sel=zx) *)
(* Helper: mux16_ scope a b sel *)
let x1 = mux16_ scope i.x (zero 16) i.zx in
```

**Common mistake:** Swapping `a` and `b` in `mux16_` calls. Double-check against the HDL:

- `Mux16(a=x, b=false, sel=zx)` → `mux16_ scope i.x (zero 16) i.zx`
- `Mux16(a=fand, b=fadd, sel=f)` → `mux16_ scope f_and f_add i.f`

## File Organization

```
hardcaml/
├── build-cache/                  # Pre-compiled during Docker image build
│   ├── lib/n2t_chips/            # Library (pre-compiled, importable)
│   │   ├── dune                  # Library build config
│   │   ├── n2t_chips.ml          # Main module + helpers
│   │   ├── n2t_chips.mli         # Public interface
│   │   ├── nand.ml, not.ml, ...  # Chip implementations
│   │   ├── nand.mli, not.mli, ...# Chip interfaces
│   │   └── not_test.ml, ...      # Test files (loaded by frontend, not compiled)
│   ├── src/                      # User circuit (replaced per request)
│   └── test/                     # User tests (replaced per request)
├── examples/n2t/                 # Student stubs
│   └── not.ml, and.ml, ...       # Placeholder implementations
└── examples/n2t_solutions/       # Reference solutions
    └── not.ml, and.ml, ...       # Hierarchical implementations
```

## Build Cache Strategy

The `build-cache/` directory is pre-compiled during Docker image build:

```dockerfile
COPY hardcaml/build-cache/ /opt/build-cache/
RUN cd /opt/build-cache && dune build @runtest --force
```

This means:

- `n2t_chips` is compiled once when the Docker image is built
- When users submit code, only their files (`src/`, `test/`) need compilation
- The pre-compiled `n2t_chips` library just needs to be linked
- Result: fast compile times for users

## How Users Complete Exercises

1. Select a chip from "Nand2Tetris" in the dropdown
2. The stub file loads with `{ out = gnd }` placeholder
3. Replace with implementation using `N2t_chips.Nand.nand`:
   ```ocaml
   let create _scope (i : _ I.t) : _ O.t =
     { out = N2t_chips.Nand.nand i.a i.a }  (* NOT = NAND(a, a) *)
   ```
4. Run to see test results and waveform
5. View "Nand2Tetris Solutions" to see reference implementation

## Project 2: Arithmetic Chips

Project 2 introduces arithmetic chips that build on Project 1 gates:

| Chip      | Description                           | Key Implementation Notes                 |
| --------- | ------------------------------------- | ---------------------------------------- |
| HalfAdder | sum + carry of 2 bits                 | `sum = a XOR b`, `carry = a AND b`       |
| FullAdder | sum + carry of 3 bits                 | Chain two HalfAdders + OR for carry      |
| Add16     | 16-bit addition                       | HalfAdder for bit 0, FullAdders for 1-15 |
| Inc16     | Increment by 1                        | `Add16(a=in, b=1)`                       |
| ALU       | Arithmetic Logic Unit with 6 controls | See detailed notes below                 |

### ALU Implementation

The ALU has 6 control bits that are applied in sequence:

```
1. if zx then x = 0        (zero x)
2. if nx then x = !x       (negate x)
3. if zy then y = 0        (zero y)
4. if ny then y = !y       (negate y)
5. if f  then out = x + y  else out = x & y
6. if no then out = !out   (negate output)
```

Output flags:

- `zr = 1` if `out == 0` (use Or8Way on both halves, then Or, then Not)
- `ng = 1` if `out < 0` (just the MSB, i.e., `msb out`)

**Library vs Solution approach:**

```ocaml
(* Library: uses Hardcaml primitives directly *)
let x1 = mux2 i.zx (zero 16) i.x in       (* note: mux2 has swapped args *)
let zr = out2 ==: (zero 16) in            (* equality comparison *)

(* Solution: uses N2t_chips helpers *)
let x1 = mux16_ scope i.x (zero 16) i.zx in  (* natural N2T order *)
let or_lo = or8way_ scope (select out2 ~high:7 ~low:0) in
let zr = not_ scope (or_ scope or_lo or_hi) in
```

## Project 3: Sequential Logic

Project 3 introduces sequential chips that use clock cycles to store state:

| Chip     | Description                      | Key Implementation Notes                          |
| -------- | -------------------------------- | ------------------------------------------------- |
| DFF      | D Flip-Flop (primitive)          | Use Hardcaml's `reg` with `Reg_spec`              |
| Bit      | 1-bit register with load enable  | `Mux(feedback, in, load) -> DFF -> out`           |
| Register | 16-bit register                  | 16 Bit chips sharing the same load                |
| RAM8     | 8-register memory                | DMux8Way for load, 8 Registers, Mux8Way16 for out |
| RAM64    | 64-register memory               | 8 RAM8s with address split [0..2] / [3..5]        |
| RAM512   | 512-register memory              | 8 RAM64s with address split [0..5] / [6..8]       |
| RAM4K    | 4096-register memory             | 8 RAM512s with address split [0..8] / [9..11]     |
| RAM16K   | 16384-register memory            | 4 RAM4Ks with address split [0..11] / [12..13]    |
| PC       | Program Counter (reset/load/inc) | Priority: reset > load > inc > maintain           |

### Sequential Chip Interfaces

Sequential chips require `clock` and `clear` signals in their I module:

```ocaml
module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; inp : 'a [@bits 16]
    ; load : 'a
    }
  [@@deriving hardcaml]
end
```

### DFF Implementation

The DFF is a primitive in Hardcaml - use `reg`:

```ocaml
let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  { out = reg spec i.inp }
```

### Bit Implementation (with load enable)

Use `reg ~enable` for a register with load enable:

```ocaml
let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  { out = reg spec ~enable:i.load i.inp }
```

### Feedback Loops with `reg_fb`

For circuits that need to read their own output (like PC), use `reg_fb`:

```ocaml
(* PC: uses feedback to compute next value *)
let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let out = reg_fb spec ~width:16 ~f:(fun feedback ->
    let open N2t_chips in
    let incval = inc16_ scope feedback in
    let o1 = mux16_ scope feedback incval i.inc in
    let o2 = mux16_ scope o1 i.inp i.load in
    mux16_ scope o2 (zero 16) i.reset)
  in
  { out }
```

### Timing Model: N2T vs Hardcaml Simulation

**Important:** The N2T specification and Hardcaml simulation have different perspectives on timing.

#### N2T Specification (Abstract)

N2T describes timing abstractly with `t` and `t+1`:

```
out(t+1) = in(t)  // DFF
if load(t) then out(t+1) = in(t) else out(t+1) = out(t)  // Bit
```

This suggests output lags input by one cycle.

#### Hardcaml Simulation (Concrete)

In Hardcaml's `Cyclesim`, a cycle captures inputs and updates outputs:

```ocaml
inputs.inp := Bits.of_int 1;   (* Set input to 1 *)
Cyclesim.cycle sim;            (* Clock edge: register captures input *)
(* After cycle: output IS 1, not the old value *)
```

The output after `cycle` reflects the input that was present before `cycle`.

#### Test Implications

When writing tests, expect the new value immediately after the cycle:

```ocaml
(* WRONG - expects one-cycle delay *)
inputs.inp := Bits.of_int 1;
Cyclesim.cycle sim;
assert (output = 0);  (* Expects old value - FAILS *)

(* CORRECT - value updates after cycle *)
inputs.inp := Bits.of_int 1;
Cyclesim.cycle sim;
assert (output = 1);  (* New value is visible - PASSES *)
```

For chips with `load` enable:

```ocaml
(* Bit register: load takes effect in same cycle *)
inputs.inp := Bits.of_int 1;
inputs.load := Bits.vdd;
Cyclesim.cycle sim;
assert (output = 1);  (* Loaded value visible immediately *)

inputs.load := Bits.gnd;
Cyclesim.cycle sim;
assert (output = 1);  (* Value maintained when load=0 *)
```

This is the same underlying behavior - the register captures on the clock edge and the simulation shows post-edge state.

## Hardcaml Gotchas

### Labeled Arguments

Hardcaml's `bit` and `select` functions require labeled arguments:

```ocaml
(* Wrong - will cause "labels omitted" errors *)
let sel0 = bit i.sel 0 in
let sel01 = select i.sel 1 0 in

(* Correct - use labeled arguments *)
let sel0 = bit i.sel ~pos:0 in
let sel01 = select i.sel ~high:1 ~low:0 in
```

### Always DSL Operators

The `Always` DSL (used in library implementations like PC) has its own operators that shadow `Signal` operators:

```ocaml
let open Always in
let%hw_var counter = Variable.reg spec ~width:16 in
compile [
  if_ i.reset [
    counter <-- zero 16        (* <-- is Always assignment *)
  ] @@ elif i.inc [
    counter <-- counter.value +: one 16  (* +: is Signal addition *)
  ] []
];
```

Key differences:

- `<--` is `Always` variable assignment (not `Signal.(<==)`)
- `counter.value` extracts the signal from an Always variable
- `if_`, `elif`, `compile` are from `Always` module

### Feedback with Wire vs reg_fb

Don't use `wire` and `<==` for feedback loops in sequential circuits. Use `reg_fb` instead:

```ocaml
(* WRONG - wire/assign pattern doesn't work well for registers *)
let feedback = wire 16 in
let out = mux16_ scope feedback i.inp i.load in
let registered = reg spec out in
feedback <== registered;  (* <== may be shadowed or cause issues *)

(* CORRECT - use reg_fb for register feedback *)
let out = reg_fb spec ~width:16 ~f:(fun feedback ->
  mux16_ scope feedback i.inp i.load)
in
```

`reg_fb` handles the feedback loop internally and is the idiomatic Hardcaml pattern.

### Unused Scope Parameter

When using `let%hw_var` or other ppx extensions, the `scope` parameter may be implicitly required even if you don't use it directly:

```ocaml
(* WRONG - _scope suggests unused, but let%hw_var needs it *)
let create _scope (i : _ I.t) : _ O.t =
  let%hw_var counter = Variable.reg spec ~width:16 in  (* Error: Unbound value scope *)
  ...

(* CORRECT - use scope and silence warning if needed *)
let create scope (i : _ I.t) : _ O.t =
  let _ = scope in  (* Silence unused warning *)
  let%hw_var counter = Variable.reg spec ~width:16 in
  ...
```

### Module Naming from Filenames

OCaml module names are derived from filenames with the first letter capitalized:

| Filename       | Module Name |
| -------------- | ----------- |
| `not.ml`       | `Not`       |
| `dmux8way.ml`  | `Dmux8way`  |
| `mux4way16.ml` | `Mux4way16` |

All N2T chip filenames use lowercase (e.g., `not.ml`, `dmux8way.ml`) which creates modules with the first letter capitalized (`Not`, `Dmux8way`).

### Using N2t_chips Helpers

When using `N2t_chips` helpers in solutions, prefer explicit module qualification for robustness:

```ocaml
(* Works but can be fragile *)
let open N2t_chips in
let ab, cd = dmux_ scope i.inp sel1 in

(* More explicit and robust *)
let ab, cd = N2t_chips.dmux_ scope i.inp sel1 in
```

## Adding New Chips

1. Add implementation to `lib/n2t_chips/chipname.ml`
2. Add interface to `lib/n2t_chips/chipname.mli`
3. Add test to `lib/n2t_chips/chipname_test.ml`
4. Update `lib/n2t_chips/dune` modules list (to exclude tests from lib compilation)
5. Export in `lib/n2t_chips/n2t_chips.ml` and `.mli`
6. Add stub to `examples/n2t/chipname.ml`
7. Add solution to `examples/n2t_solutions/chipname.ml`
8. Update `frontend/src/examples/hardcaml-examples.ts` with imports and entries
9. Add chip name to `api/tests/examples.py` `N2T_CHIPS` list for test coverage
