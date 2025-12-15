# Hardcaml Web IDE

A web-based IDE for compiling and running [Hardcaml](https://github.com/janestreet/hardcaml) circuits with waveform visualization.

## Overview

This project provides a Docker-based API that:

- Accepts Hardcaml circuit code and test files
- Compiles them using the OxCaml 5.2 + Hardcaml toolchain
- Runs tests and captures waveform output
- Returns ASCII waveforms and test results

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- ~4GB disk space for the Docker image (OCaml toolchain is large)

### Build and Run

```bash
cd aoc/fpga/hardcaml-web-ide

# Build the Docker image (takes 10-20 minutes first time)
docker compose build

# Start the server
docker compose up
```

The API will be available at `http://localhost:8000`.

### Test the API

```bash
# Health check

# Compile a circuit (see examples below)
curl -X POST http://localhost:8000/compile \
  -H "Content-Type: application/json" \
  -d @examples/counter/request.json
```

## API Reference

### `GET /health`

Health check endpoint.

**Response:**

```json
{
  "status": "healthy",
  "service": "hardcaml-web-ide"
}
```

### `POST /compile`

Compile and run Hardcaml code.

**Request:**

```json
{
  "files": {
    "circuit.ml": "open! Core\nopen! Hardcaml...",
    "circuit.mli": "(* optional interface *)",
    "test.ml": "open! Core..."
  },
  "timeout_seconds": 30
}
```

**Response (success):**

```json
{
  "success": true,
  "output": "(Result (count 15))",
  "waveform": "┌Signals──────────┐┌Waves────────────┐\n...",
  "compile_time_ms": 1200,
  "run_time_ms": 50
}
```

**Response (error):**

```json
{
  "success": false,
  "error_type": "compile_error",
  "error_message": "File \"circuit.ml\", line 5...",
  "stage": "compile"
}
```

### `GET /examples`

List available example circuits.

## Project Structure

```
hardcaml-web-ide/
├── Dockerfile              # Multi-stage build with OxCaml + Hardcaml
├── docker-compose.yml      # Local development setup
├── api/
│   ├── main.py             # FastAPI server
│   ├── compiler.py         # Compilation logic
│   └── requirements.txt    # Python dependencies
├── template/               # Base project structure
│   ├── dune-project
│   ├── src/
│   │   └── dune
│   └── test/
│       └── dune
└── examples/               # Example circuits
    ├── counter/
    └── day1_part1/
```

## Writing Circuits

### File Structure

Your circuit needs at minimum two files:

1. **circuit.ml** - The circuit implementation
2. **test.ml** - Test file with expect tests

Optionally, you can include:

- **circuit.mli** - Interface file

### Circuit Template

```ocaml
(* circuit.ml *)
open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; (* your inputs here *)
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { (* your outputs here *)
    }
  [@@deriving hardcaml]
end

let create scope (inputs : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:inputs.clock ~clear:inputs.clear () in
  (* your circuit logic here *)
  { (* outputs *) }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"my_circuit" create
;;
```

### Test Template

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

  (* Your test logic here *)
  inputs.clear := Bits.vdd;
  cycle ();
  inputs.clear := Bits.gnd;

  (* Print results *)
  print_s [%message "Result" (* your values *)];
  cycle ()
;;

let%expect_test "my test" =
  Harness.run_advanced
    ~waves_config:Waves_config.no_waves
    ~create:Circuit.hierarchical
    ~trace:`All_named
    ~print_waves_after_test:(fun waves ->
      Waveform.print
        ~display_width:120
        ~wave_width:2
        waves)
    run_testbench;
  [%expect {| (* expected output *) |}]
;;
```

## Development

### Modifying the API

The API code is mounted as a volume in development mode. Changes to files in `api/` will be reflected after restarting uvicorn.

```bash
docker-compose restart
```

### Rebuilding the Docker Image

If you modify the Dockerfile or template:

```bash
docker-compose build --no-cache
```

### Running Tests Locally

If you have the OCaml toolchain installed locally (see `../README.md`):

```bash
cd examples/counter
# Copy files to template and run
```

## Toolchain Details

This project uses:

- **OxCaml 5.2** - Jane Street's OCaml distribution
- **Hardcaml** - Hardware design library
- **Hardcaml_waveterm** - Waveform visualization
- **Hardcaml_test_harness** - Testing utilities

The Docker image pre-installs all dependencies and pre-compiles the template project, so user builds only compile their code (~2-5 seconds instead of ~30 seconds).

## Troubleshooting

### Build takes too long

The first Docker build downloads and compiles the entire OCaml toolchain. Subsequent builds use Docker layer caching.

### Out of memory during build

The OCaml compiler needs significant memory. Ensure Docker has at least 4GB RAM allocated.

### Test timeout

Increase the `timeout_seconds` parameter in your request. Complex circuits may need more time.

## License

MIT
