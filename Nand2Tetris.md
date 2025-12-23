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

| Function | Signature                       |
| -------- | ------------------------------- |
| `nand_`  | `scope -> a -> b -> out`        |
| `not_`   | `scope -> a -> out`             |
| `and_`   | `scope -> a -> b -> out`        |
| `or_`    | `scope -> a -> b -> out`        |
| `xor_`   | `scope -> a -> b -> out`        |
| `mux_`   | `scope -> a -> b -> sel -> out` |
| `dmux_`  | `scope -> inp -> sel -> (a, b)` |

## Mux Convention

**Important:** The N2T and Hardcaml mux conventions differ:

| Convention                   | sel=0     | sel=1      |
| ---------------------------- | --------- | ---------- |
| N2T                          | out = a   | out = b    |
| Hardcaml `mux2 sel high low` | out = low | out = high |

So in our library implementation:

```ocaml
(* mux2 sel high low -> we pass (sel, b, a) to get N2T behavior *)
{ out = mux2 i.sel i.b i.a }
```

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

## Adding New Chips

1. Add implementation to `lib/n2t_chips/chipname.ml`
2. Add interface to `lib/n2t_chips/chipname.mli`
3. Add test to `lib/n2t_chips/chipname_test.ml`
4. Update `lib/n2t_chips/dune` modules list (to exclude tests from lib compilation)
5. Export in `lib/n2t_chips/n2t_chips.ml` and `.mli`
6. Add stub to `examples/n2t/chipname.ml`
7. Add solution to `examples/n2t_solutions/chipname.ml`
8. Update `frontend/src/examples/hardcaml-examples.ts` with imports and entries
