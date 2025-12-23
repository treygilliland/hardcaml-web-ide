# Hardcaml Web IDE

A web-based IDE for compiling and running [Hardcaml](https://github.com/janestreet/hardcaml) circuits with waveform visualization.

## Quick Start

```bash
# Build base image (first time, ~10-20 min)
make build-base

# Development mode (hot reload)
make dev

# Run tests
make test
```

- **Development**: Frontend at `http://localhost:5173`, API at `http://localhost:8000`
- **Production**: `make up` → Both at `http://localhost:8000`

## Project Structure

```
hardcaml-web-ide/
├── api/                    # FastAPI backend
│   ├── main.py
│   ├── compiler.py
│   ├── test_runner.py      # Direct dune test runner
│   ├── pyproject.toml      # Python deps
│   └── tests/
│       ├── examples.py     # Manifest for tests to run
│       └── test_examples.py
├── frontend/               # React + Vite frontend
│   └── src/examples/
│       └── hardcaml-examples.ts
├── hardcaml/
│   ├── examples/           # Example circuits
│   │   ├── counter/
│   │   ├── fibonacci/
│   │   ├── n2t_solutions/  # N2T reference implementations
│   │   └── ...
│   └── build-cache/        # Pre-built dune project
├── Dockerfile              # Production
├── Dockerfile.dev          # Development
└── Makefile
```

## Testing

Two-tier testing validates both OCaml code and API integration:

```bash
make test          # Run both (~30s)
make test-dune     # All 19 examples via dune (~5s)
make test-api      # Key examples via FastAPI TestClient (~25s)
```

### Test Architecture

| Tier | Command          | Examples                     | What it tests                               |
| ---- | ---------------- | ---------------------------- | ------------------------------------------- |
| Dune | `make test-dune` | All 19                       | OCaml code via `compiler.compile_and_run()` |
| API  | `make test-api`  | counter, n2t_mux, day1_part1 | Full API flow via TestClient                |

Both run inside Docker. Use `test-dune` for comprehensive OCaml validation, `test-api` for API smoke tests.

### Adding Examples to Tests

**Dune tests** (`api/tests/examples.py`):

- Add to `STANDARD_EXAMPLES` for `hardcaml/examples/<name>/` structure
- Add to `N2T_CHIPS` for N2T solutions

**API tests** (`api/tests/test_examples.py`):

- Add example ID to the `@pytest.mark.parametrize` list

## Python Dependencies

Uses [uv](https://docs.astral.sh/uv/) for dependency management:

```bash
cd api
uv sync                    # Install main deps
uv sync --extra test       # Include test deps
uv run pytest tests/ -v    # Run tests
uv add <package>           # Add dependency
uv lock                    # Regenerate lockfile
```

Dependencies defined in `api/pyproject.toml` with `test` optional group.

## Development

### Hot Reload

| Component               | Mounted | Hot Reload       |
| ----------------------- | ------- | ---------------- |
| `api/`                  | Yes     | uvicorn --reload |
| `frontend/`             | Yes     | Vite HMR         |
| `hardcaml/examples/`    | Yes     | Vite watches     |
| `hardcaml/build-cache/` | No      | Requires rebuild |

### When to Rebuild

```bash
docker compose -f docker-compose.dev.yml build backend
```

- Changes to `hardcaml/build-cache/`
- Changes to `Dockerfile.dev` or `Dockerfile.base`
- Changes to `api/pyproject.toml` or `api/uv.lock`

## Adding Examples

### 1. Create OCaml Files

Create `hardcaml/examples/<name>/` with:

| File          | Required | Description                                                      |
| ------------- | -------- | ---------------------------------------------------------------- | --- | ---------------------------------------- |
| `circuit.ml`  | Yes      | Implementation with `I`, `O` modules and `hierarchical` function |
| `circuit.mli` | Yes      | Interface file                                                   |
| `test.ml`     | Yes      | Test with `[%expect {                                            |     | }]`and`===WAVEFORM_START/END===` markers |
| `input.txt`   | No       | Input data (replaces `INPUT_DATA` placeholder in test.ml)        |

### 2. Register in Frontend

Add to `frontend/src/examples/hardcaml-examples.ts`:

```typescript
import myCircuit from "@hardcaml/examples/<name>/circuit.ml?raw";
import myInterface from "@hardcaml/examples/<name>/circuit.mli?raw";
import myTest from "@hardcaml/examples/<name>/test.ml?raw";

const myExample: HardcamlExample = {
  name: "My Example",
  category: "hardcaml", // or "advent", "n2t", "n2t_solutions"
  circuit: myCircuit,
  interface: myInterface,
  test: myTest,
};

// Add to examples record
export const examples: Record<ExampleKey, HardcamlExample> = {
  // ...existing
  my_example: myExample,
};
```

### 3. Add to Test Manifest

For examples that should pass tests, add to `api/tests/examples.py`:

```python
STANDARD_EXAMPLES = ["counter", "fibonacci", ..., "my_example"]
```

Run `make test-dune` to verify the example passes.

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
