# Hardcaml Web IDE API (backend)

This directory is the **FastAPI backend** that powers compilation + execution of Hardcaml circuits for the Web IDE.

The backend is intentionally thin: HTTP handlers validate input, then delegate almost everything to `compiler.compile_and_run()`.

## See also

- **Project overview / how to run the full stack**: [`../README.md`](../README.md)
- **OCaml + dune fast iteration (in-place in `/opt/build-cache`)**: [`../hardcaml/README.md`](../hardcaml/README.md)
- **Frontend**: [`../frontend/README.md`](../frontend/README.md)

## Entry points

- `main.py`: minimal server entry point (runs `uvicorn` with `app`).
- `app.py`: FastAPI app factory + middleware (CORS, rate limit handler) + optional static file serving.
- `routes.py`: `/health` + `/compile`.

## API surface

### `GET /health`

Returns a small JSON payload for liveness checks:

- `{"status": "healthy", "service": "hardcaml-web-ide"}`

### `POST /compile`

Request schema (see `schemas.py`):

- `files`: `dict[str, str]` mapping **filename → content**
- `timeout_seconds`: int (1–120), default 30

`routes.py` enforces:

- At least one `*.ml` file besides `test.ml`
- `test.ml` must be present

Response schema is `CompileResponse` (success/output/waveform/error fields + timing + test counts).

Example request body:

```json
{
  "files": {
    "circuit.ml": "(* ... *)",
    "circuit.mli": "(* ... *)",
    "test.ml": "(* ... *)"
  },
  "timeout_seconds": 30
}
```

## Request flow (what happens on `/compile`)

The compile pipeline is implemented in `compiler.py`:

1. **Create an isolated build dir** under the OS temp directory.
2. **Populate a dune project**:
   - Preferred path: copy the prebuilt dune project from `BUILD_CACHE_DIR = /opt/build-cache` (fast in Docker).
   - Fallback path (for local dev without the image cache): synthesize a minimal dune project structure.
3. **Write user files**:
   - `test.ml` is written to `<build_dir>/test/test.ml`
   - any `*.ml` / `*.mli` is written to `<build_dir>/src/<filename>`
4. **Run dune**:
   - `dune build @runtest --auto-promote`
5. **Parse output**:
   - Pulls out PASS/FAIL lines and an optional summary line (see “Output contract” below)
   - Extracts waveform text between markers
   - Optionally reads VCD content from `/tmp/waveform.vcd`
6. **Return `CompileResult`**, then **best-effort cleanup** of the build dir.

## Output + waveform contract

The backend can’t “understand” arbitrary OCaml output; instead it parses a couple conventions from the combined dune stdout/stderr:

- **Waveform markers**:
  - Start: `===WAVEFORM_START===`
  - End: `===WAVEFORM_END===`
- **Test summary marker**:
  - `===TEST_SUMMARY===` followed by a line containing `TESTS: X passed, Y failed`
- **Per-test lines** (captured into `output`):
  - Lines starting with `PASS:` or `FAIL:`

Note: dune/ppx-expect output sometimes contains diff prefixes; `parse_output()` strips common prefixes like `+    `, `-    `, `|    `.

## Error classification

`compiler.parse_error()` buckets common OCaml/dune failures into:

- `syntax_error`, `type_error`, `unbound_error`
- `timeout_error`
- fallback: `compile_error`

Separately, if compilation succeeded but tests fail, the API returns:

- `error_type="test_failure"` with `stage="test"`

If dune returns non-zero without test counts, it’s treated as a runtime crash:

- `error_type="runtime_error"` with `stage="test"`

## Static file serving (dev vs prod)

`config.py` computes:

- `STATIC_DIR`: `/app/static` (prod image) or `../frontend/dist` (local build output)
- `DEV_MODE`: true if `STATIC_DIR/index.html` is missing

In **prod mode** (`DEV_MODE == False`), `app.py`:

- mounts `/assets` from the built frontend
- serves `/` (SPA `index.html`) and `/favicon.png`

In **dev mode**, the backend is API-only (frontend is served separately by Vite).

## Rate limiting

Rate limiting is done with `slowapi` in `rate_limit.py` and applied on `/compile`:

- limit is `RATE_LIMIT_PER_MINUTE` (env var, default 10)
- the client id uses `CF-Connecting-IP` when present (Cloudflare), otherwise the remote address
- the 429 handler returns a JSON payload shaped like a compile failure (`success: False`, `error_type: "rate_limit"`) plus a `Retry-After` header

## Tests + test runner

There are two “test runner” paths:

- **Direct runner**: `test_runner.py`
  - Calls `compiler.compile_and_run()` directly (no HTTP).
  - Uses the example manifest in `tests/examples.py`.
  - Intended to run **inside the Docker environment** where dune/opam/toolchain exist.
- **API integration tests**: `tests/test_examples.py`
  - Uses FastAPI `TestClient` to exercise `/compile` end-to-end.
  - Also uses `tests/examples.py` to provide realistic circuit/test input.

If you want the fastest “OCaml programmer” iteration loop (stage files into `/opt/build-cache` and run dune), use `hardcaml/dev_runner.py` documented in [`../hardcaml/README.md`](../hardcaml/README.md).

The example manifest (`tests/examples.py`) loads two categories:

- `STANDARD_EXAMPLES`: from `hardcaml/examples/<example_id>/{circuit.ml,circuit.mli,test.ml}` (+ optional `input.txt`)
  - If `input.txt` exists, it replaces `INPUT_DATA` in `test.ml`.
- `N2T_CHIPS`: from `hardcaml/examples/n2t_solutions/<chip>.ml` plus interface/tests from the prebuilt `hardcaml/build-cache/lib/n2t_chips/`.

## Running (inside docker)

From the repo root (recommended):

```bash
make dev
docker compose -f docker-compose.dev.yml exec backend uv run python -m pytest
docker compose -f docker-compose.dev.yml exec backend uv run python test_runner.py -l
docker compose -f docker-compose.dev.yml exec backend uv run python test_runner.py counter
```

If you want to run the API server manually inside the backend container:

```bash
docker compose -f docker-compose.dev.yml exec backend uv run python main.py
```
