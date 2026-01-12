# Hardcaml Web IDE

Web-based IDE for [Hardcaml](https://github.com/janestreet/hardcaml) circuits with waveform visualization.

## Quick Start

```bash
make dev      # Development (frontend :5173, API :8000)
make test     # Run tests
make up       # Production (:8000)
```

## Project Structure

```
├── api/                    # FastAPI compilation and server backend
├── frontend/               # pnpm workspace (see frontend/README.md)
│   ├── ui/                 # @hardcaml/ui - shared components
│   ├── ide/                # @hardcaml/ide - main IDE app
│   └── docs/               # @hardcaml/docs - Astro docs site
├── hardcaml/               # hardcaml source code
│   ├── examples/           # Example circuits
│   └── build-cache/        # Pre-built dune project
├── Dockerfile              # App image (uses base)
├── Dockerfile.base         # Base image (OCaml toolchain)
└── .github/workflows/      # GitHub Actions (builds base image)
```

## Architecture

The project is split into:

1. **Python FastAPI Backend** (`api/`) - Compiles and runs Hardcaml circuits, serves the IDE app in production
2. **Frontend Workspace** (`frontend/`) - pnpm monorepo containing:
   - `@hardcaml/ui` - Shared React components, hooks, and API client
   - `@hardcaml/ide` - Main IDE application (React + Vite)
   - `@hardcaml/docs` - Documentation site (Astro Starlight)

The frontend uses a pnpm workspace to share code between the IDE and docs site. The IDE app is bundled with the API in production, while the docs site is deployed separately to GitHub Pages.

See [frontend/README.md](frontend/README.md) for details on the frontend architecture and development workflow.

## Development

| Component          | URL            | Hot Reload       |
| ------------------ | -------------- | ---------------- |
| Frontend           | localhost:5173 | Vite HMR         |
| API                | localhost:8000 | uvicorn --reload |
| hardcaml/examples/ | -              | Vite watches     |

Rebuild backend after changing `Dockerfile.base`, `api/pyproject.toml`, or `hardcaml/build-cache/`:

```bash
docker compose -f docker-compose.dev.yml build backend
```

## Testing

```bash
make test        # All tests (~30s)
make test-dune   # OCaml examples via dune (~5s)
make test-api    # API integration tests (~25s)
```

| Tier | Command          | What it tests                               |
| ---- | ---------------- | ------------------------------------------- |
| Dune | `make test-dune` | OCaml code via `compiler.compile_and_run()` |
| API  | `make test-api`  | Full API flow via TestClient                |

## Frontend

The frontend is a pnpm workspace containing three packages:
- **IDE** - React + TypeScript + Vite application
- **Docs** - Astro Starlight documentation site
- **UI** - Shared components and utilities

The workspace structure allows code sharing between the IDE and docs while keeping them as separate applications. See [frontend/README.md](frontend/README.md) for architecture details and development instructions.

### Analytics

Analytics (PostHog) is enabled by default in production but automatically disabled on localhost.
To explicitly disable it, set `VITE_POSTHOG_ENABLED=false` in your environment.

To connect to a PostHog instance, set:

- `VITE_PUBLIC_POSTHOG_KEY` - Your PostHog project API key
- `VITE_PUBLIC_POSTHOG_HOST` - Your PostHog host (defaults to `https://us.i.posthog.com`)

## Python Dependencies

Uses [uv](https://docs.astral.sh/uv/) for dependency management:

```bash
cd api
uv sync                    # Install deps
uv sync --extra test       # Include test deps
uv add <package>           # Add dependency
```

## Adding Examples

1. Create `hardcaml/examples/<name>/` with:

   - `circuit.ml` - Implementation with `I`, `O` modules and `hierarchical` function
   - `circuit.mli` - Interface file
   - `test.ml` - Test with `[%expect {| |}]` and `===WAVEFORM_START/END===` markers
   - `input.txt` (optional) - Input data

2. Register in `frontend/src/examples/hardcaml-examples.ts`

3. Add to `api/tests/examples.py` for test coverage

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

let create scope (i : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  { out = reg spec ~enable:vdd (i.clear |: gnd) }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"my_circuit" create
;;
```

## Toolchain

- **OxCaml 5.2** - Jane Street's OCaml distribution
- **Hardcaml** - Hardware design library
- **Hardcaml_waveterm** - Waveform visualization
- **Hardcaml_test_harness** - Testing utilities

## Deployment

See [DEPLOY.md](DEPLOY.md) for Railway setup.

## Environment Variables

Copy `.env.example` to `.env` and configure:

- `RATE_LIMIT_PER_MINUTE`: API rate limit (default: 10)
- `VITE_PUBLIC_POSTHOG_KEY`: PostHog API key (optional, for analytics)
- `VITE_PUBLIC_POSTHOG_HOST`: PostHog host URL (optional)
- `VITE_POSTHOG_ENABLED`: Enable/disable analytics (optional)
- `GITHUB_USERNAME`: Only needed if building/pushing your own images (defaults to `treygilliland`)

**Note:** Docker images are publicly available at `ghcr.io/treygilliland/`, so you can use them directly without configuration.

See `.env.example` for all available options.
