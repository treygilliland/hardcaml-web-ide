# Hardcaml (OCaml) code: develop + test directly

This directory contains the OCaml sources used by the Hardcaml Web IDE:

- `examples/`: small standalone example circuits and tests (e.g. counter, fibonacci)
- `aoc/`: Advent of Code circuits and tests
- `n2t/`: Nand2Tetris student stubs + reference solutions
- `build-cache/`: a **dune project** used as the compilation baseline inside the Web IDE

## See also

- **Project overview / how to run the full stack**: [`../README.md`](../README.md)
- **Backend compile API + backend test runner**: [`../api/README.md`](../api/README.md)
- **Nand2Tetris design notes**: [`../docs/Nand2Tetris.md`](../docs/Nand2Tetris.md)

If you want to write OCaml and run tests directly (without the web UI), the fastest path is to use the Docker dev environment so you get the exact OCaml/opam toolchain used by the backend.

## The dune project you actually run

The runnable dune project is `build-cache/` (mounted in Docker and also copied into `/opt/build-cache` inside the backend image).

It uses a **flat layout** (all files in root, no `src/` or `test/` subdirectories):

- `dune`: defines `user_circuit` (your circuit modules) and `user_test` (your tests with `(inline_tests)`)
- Circuit files (`.ml`, `.mli`) and `test.ml` are written directly to the root
- `harness_utils.ml`: test utilities (copied from templates)
- `n2t_chips` (`lib/n2t_chips/`): prebuilt Nand2Tetris "library chips" + helpers (for N2T projects)

The Web IDE backend uses `setup_project` from `api/compiler.py` to create a consistent flat layout.

To run examples locally (CLI alternative to the web IDE), use `api/hardcaml_runner.py` as described in [`../api/README.md`](../api/README.md).

## Example manifest

All examples (standard, AOC, and N2T) are managed through a unified manifest system:

- `examples_manifest.py`: Single source of truth for loading and listing examples
  - Used by `api/hardcaml_runner.py` (CLI runner) and the web IDE (for loading examples)
  - Provides consistent example loading across all code paths
  - Handles standard examples, AOC examples, and N2T chips (with stub/solution variants)

## Minimal circuit template

Most examples follow this pattern: define `I`/`O` interfaces, a `create` function, and a `hierarchical` wrapper.

```ocaml
open! Core
open! Hardcaml
open! Signal

module I = struct
  type 'a t = { clock : 'a; clear : 'a }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t = { out : 'a [@bits 8] }
  [@@deriving hardcaml]
end

let create _scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  { out = reg spec ~enable:vdd (zero 8) }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"my_circuit" create
;;
```

## Quickstart: run tests inside Docker

From `hardcaml-web-ide/`:

```bash
make dev
docker compose -f docker-compose.dev.yml exec backend bash
```

Inside the container, use `hardcaml_runner.py` to run examples (CLI alternative to the web IDE):

```bash
# List available examples
uv run python /api/hardcaml_runner.py --list

# Run a specific example
uv run python /api/hardcaml_runner.py counter
uv run python /api/hardcaml_runner.py day1_part1
uv run python /api/hardcaml_runner.py n2t_alu

# Run all examples
uv run python /api/hardcaml_runner.py

# Verbose output
uv run python /api/hardcaml_runner.py -v counter
```

## Iterate on an existing example

Examples live in:

- `/hardcaml/examples/<example_id>/` (standalone examples like `counter`)
- `/hardcaml/aoc/<example_id>/` (AoC examples like `day1_part1`)

These are volume-mounted from `hardcaml-web-ide/hardcaml/`.

### What hardcaml_runner does

`api/hardcaml_runner.py` is a CLI alternative to the web IDE:

- loads the example using the unified `examples_manifest.py` module
- uses the same `compile_and_run` function as the web IDE API
- creates an isolated temp directory with flat layout (matching web IDE)
- runs `dune build @runtest` and parses the output
- returns test results with the same format as the web IDE

This ensures complete consistency between CLI and web IDE - you get identical results whether you use the web IDE or the CLI runner.

## Using the API directly

You can also use the API endpoint directly for testing:

```bash
# Start the API server
docker compose -f docker-compose.dev.yml exec backend uv run python /api/main.py

# Then use curl or the web IDE to POST to /compile
```

## Writing tests that work well in the Web IDE

The web backend parses conventions out of dune/expect output:

- Lines beginning with `PASS:` / `FAIL:` are surfaced as the “test output”
- Waveform text is captured between:
  - `===WAVEFORM_START===`
  - `===WAVEFORM_END===`
- A summary line is parsed after `===TEST_SUMMARY===` if it contains `TESTS: X passed, Y failed`
- If you write a VCD to `/tmp/waveform.vcd`, the API will return it as `waveform_vcd`

See `examples/counter/test.ml` for a minimal pattern using `Hardcaml_test_harness` and `Hardcaml_waveterm`.

## Nand2Tetris layout (stubs vs solutions vs library)

There are three “tiers” of N2T chips:

- `build-cache/lib/n2t_chips/`: efficient library chips + helper functions (compiled into the dune project)
- `n2t/stubs/`: student stubs (loaded by the IDE for exercises)
- `n2t/solutions/`: reference solutions (hierarchical, readable)

More details: `../docs/Nand2Tetris.md`.
