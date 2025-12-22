# Hardcaml Web IDE

A web-based IDE for compiling and running [Hardcaml](https://github.com/janestreet/hardcaml) circuits with waveform visualization.

## Quick Start

```bash
# Build base image (first time, ~10-20 min)
make base

# Production mode
make up

# Development mode (hot reload)
make dev
```

- **Production**: `http://localhost:8000`
- **Development**: Frontend at `http://localhost:5173`, API at `http://localhost:8000`

## Project Structure

```
hardcaml-web-ide/
├── api/                    # FastAPI backend
│   ├── main.py
│   └── compiler.py
├── frontend/               # React + Vite frontend
│   └── src/
│       └── examples/
│           └── hardcaml-examples.ts  # Loads OCaml via ?raw imports
├── hardcaml/               # OCaml sources
│   ├── examples/           # Example circuits (.ml, .mli, test.ml)
│   │   ├── counter/
│   │   ├── fibonacci/
│   │   ├── day1_part1/
│   │   └── day1_part2/
│   └── build-cache/        # Pre-built dune project for fast compilation
├── Dockerfile              # Production multi-stage build
├── Dockerfile.dev          # Development backend
├── docker-compose.yml      # Production
└── docker-compose.dev.yml  # Development
```

## Development vs Production

### Production (`make up` / `docker-compose.yml`)

Single container serving both API and static frontend. **Requires rebuild for any changes.**

### Development (`make dev` / `docker-compose.dev.yml`)

Two containers with hot reload capabilities:

| Component               | What's Mounted             | Hot Reload?                                                    |
| ----------------------- | -------------------------- | -------------------------------------------------------------- |
| `api/`                  | Volume mounted             | Yes (uvicorn --reload)                                         |
| `frontend/`             | Volume mounted             | Yes (Vite HMR)                                                 |
| `hardcaml/`             | Volume mounted to frontend | Yes (Vite watches)                                             |
| `hardcaml/build-cache/` | Copied at build            | No - requires `docker compose -f docker-compose.dev.yml build` |

**When to rebuild dev:**

- Changes to `hardcaml/build-cache/` (dune config, test harness setup)
- Changes to `Dockerfile.dev` or `Dockerfile.base`
- New Python dependencies in `api/requirements.txt`

## Adding Examples

1. Create OCaml files in `hardcaml/examples/<name>/`:

   - `circuit.ml` - Implementation
   - `circuit.mli` - Interface
   - `test.ml` - Test with empty `[%expect {| |}]`
   - `input.txt` - Optional input data

2. Add imports and export in `frontend/src/examples/hardcaml-examples.ts`:

```typescript
import myCircuit from "@hardcaml/examples/<name>/circuit.ml?raw";
import myInterface from "@hardcaml/examples/<name>/circuit.mli?raw";
import myTest from "@hardcaml/examples/<name>/test.ml?raw";

export const myExample: HardcamlExample = {
  name: "My Example",
  category: "hardcaml",
  circuit: myCircuit,
  interface: myInterface,
  test: myTest,
};
```

3. Add to the `examples` record in the same file

## API Reference

### `POST /compile`

```json
{
  "files": {
    "circuit.ml": "...",
    "circuit.mli": "...",
    "test.ml": "..."
  },
  "timeout_seconds": 30
}
```

### `GET /health`

Returns `{"status": "healthy"}`.

## Circuit Template

```ocaml
(* circuit.ml *)
open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { clock : 'a; clear : 'a; (* inputs *) }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { (* outputs *) }
  [@@deriving hardcaml]
end

let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  (* circuit logic *)
  { (* outputs *) }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"my_circuit" create
;;
```

## Test Template

```ocaml
(* test.ml *)
open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Circuit = User_circuit.Circuit
module Harness = Cyclesim_harness.Make (Circuit.I) (Circuit.O)

let run_testbench (sim : Harness.Sim.t) =
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in
  let cycle () = Cyclesim.cycle sim in
  (* test logic *)
  print_s [%message "Result" (* values *)];
  cycle ()
;;

let print_waves_and_save_vcd waves =
  print_endline "===WAVEFORM_START===";
  Waveform.print ~display_width:100 ~wave_width:2 waves;
  print_endline "===WAVEFORM_END===";
  Waveform.Serialize.marshall_vcd waves "/tmp/waveform.vcd"
;;

let%expect_test "test" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:`All_named
    ~print_waves_after_test:print_waves_and_save_vcd
    run_testbench;
  [%expect {| |}]
;;
```

## Toolchain

- **OxCaml 5.2** - Jane Street's OCaml distribution
- **Hardcaml** - Hardware design library
- **Hardcaml_waveterm** - Waveform visualization
- **Hardcaml_test_harness** - Testing utilities

The Docker image pre-compiles dependencies in the build cache, so user builds take ~2-5 seconds.
