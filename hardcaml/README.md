# Hardcaml (OCaml) code: develop + test directly

This directory contains the OCaml sources used by the Hardcaml Web IDE:

- `examples/`: example circuits and tests (AoC + N2T stubs/solutions)
- `build-cache/`: a **dune project** used as the compilation baseline inside the Web IDE

## See also

- **Project overview / how to run the full stack**: [`../README.md`](../README.md)
- **Backend compile API + backend test runner**: [`../api/README.md`](../api/README.md)
- **Nand2Tetris design notes**: [`../docs/Nand2Tetris.md`](../docs/Nand2Tetris.md)

If you want to write OCaml and run tests directly (without the web UI), the fastest path is to use the Docker dev environment so you get the exact OCaml/opam toolchain used by the backend.

## The dune project you actually run

The runnable dune project is `build-cache/` (mounted in Docker and also copied into `/opt/build-cache` inside the backend image).

It defines:

- `user_circuit` (`build-cache/src/dune`): your circuit modules (compiled as a library)
- `user_test` (`build-cache/test/dune`): your tests (a library with `(inline_tests)` via `ppx_expect`)
- `n2t_chips` (`build-cache/lib/n2t_chips/`): prebuilt Nand2Tetris “library chips” + helpers

The Web IDE backend uses the same structure: it copies `/opt/build-cache` into a fresh temp dir, writes your `src/` + `test/` files, then runs `dune build @runtest --auto-promote`.

If you want to test “through the backend” (same temp-dir isolation + output parsing the IDE uses), run `api/test_runner.py` as described in [`../api/README.md`](../api/README.md).

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

## Quickstart (recommended): run dune tests inside Docker

From `hardcaml-web-ide/`:

```bash
make dev
docker compose -f docker-compose.dev.yml exec backend bash
```

Inside the container, the fastest workflow is to **stage an example** into `/opt/build-cache` and run dune:

```bash
uv run python /hardcaml/dev_runner.py --list
uv run python /hardcaml/dev_runner.py counter
uv run python /hardcaml/dev_runner.py day1_part1
uv run python /hardcaml/dev_runner.py n2t_alu
```

## Iterate on an existing example

Examples live in `/hardcaml/examples/<example_id>/` inside the container (volume-mounted from `hardcaml-web-ide/hardcaml/examples/`).

### What the dev runner does

`/hardcaml/dev_runner.py <example_id>`:

- clears previously-staged `*.ml`/`*.mli` from `/opt/build-cache/src`
- writes the selected example’s circuit modules into `/opt/build-cache/src`
- writes the selected example’s `test.ml` to `/opt/build-cache/test/test.ml`
- for AoC examples with `input.txt`, it injects the input by replacing `INPUT_DATA` in `test.ml`
- runs `dune build @runtest --auto-promote` (pass `--no-run` to only stage files)

## N2T stubs vs solutions (dev runner)

By default, `n2t_<chip>` stages from `examples/n2t_solutions/<chip>.ml`.

To stage the **student stub** instead:

```bash
uv run python /hardcaml/dev_runner.py --use-stub n2t_alu
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
- `examples/n2t/`: student stubs (loaded by the IDE for exercises)
- `examples/n2t_solutions/`: reference solutions (hierarchical, readable)

More details: `../docs/Nand2Tetris.md`.
