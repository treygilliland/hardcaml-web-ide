<div align="center">
  <img src="frontend/hardcaml-simple-transparent.png" alt="Hardcaml Logo" width="200" />
</div>

# Hardcaml Web IDE

Web-based IDE for [Hardcaml](https://github.com/janestreet/hardcaml) circuits with waveform visualization.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

The [Hardcaml](https://github.com/janestreet/hardcaml) library and logo are developed by [Jane Street](https://www.janestreet.com/) and are also licensed under the MIT License.

## Quick Start

```bash
make dev      # Start all development services (backend :8000, frontend :5173, docs :4321)
make test     # Run tests in docker containers
make up       # Start production services
make down     # Stop all services
make logs     # View logs from all services
make clean    # Stop services and remove volumes
```

## Project Structure

```
├── api/                  		# FastAPI compilation and server backend
├── frontend/             		# pnpm workspace (see frontend/README.md)
│   ├── ui/               		# @hardcaml/ui    - shared components
│   ├── ide/              		# @hardcaml/ide   - main IDE app
│   └── docs/             		# @hardcaml/docs  - Astro docs site
├── hardcaml/             		# hardcaml source code
│   ├── examples/         		# Example circuits
│   └── build-cache/      		# Pre-built dune project
├── Dockerfile            		# App image (uses base)
├── Dockerfile.base       		# Base image (OCaml toolchain)
├── docker-compose.yml    		# Production services
├── docker-compose.dev.yml    # Development services
├── frontend/
│   ├── Dockerfile.docs         # Docs site image
│   └── Dockerfile.frontend.dev # Frontend dev image
└── .github/workflows/          # GitHub Actions (builds base image)
```

## Architecture

The project is split into:

1. **Python FastAPI Backend** (`api/`) - Compiles and runs Hardcaml circuits, serves the IDE app in production
2. **Frontend Workspace** (`frontend/`) - pnpm monorepo containing:
   - `@hardcaml/ui` - Shared React components, hooks, and API client
   - `@hardcaml/ide` - Main IDE application (React + Vite)
   - `@hardcaml/docs` - Documentation site (Astro Starlight)

The frontend uses a pnpm workspace to share code between the IDE and docs site. The IDE app is bundled with the API in production, while the docs site runs as a separate service in both development and production.

See [frontend/README.md](frontend/README.md) for details on the frontend architecture and development workflow.

## Ports

### Development (`make dev`)

| Service  | Port | Description                      |
| -------- | ---- | -------------------------------- |
| Backend  | 8000 | FastAPI server (hot reload)      |
| Frontend | 5173 | Vite dev server (IDE)            |
| Docs     | 4321 | Astro dev server (documentation) |

### Production (`make up`)

| Service | Port | Description                       |
| ------- | ---- | --------------------------------- |
| IDE/API | 8000 | FastAPI serving IDE + compile API |
| Docs    | 8080 | nginx serving static docs site    |

## Development

All development happens in Docker containers with hot reload enabled. The `make dev` command starts three services:

| Service  | URL            | Hot Reload       | Description        |
| -------- | -------------- | ---------------- | ------------------ |
| Backend  | localhost:8000 | uvicorn --reload | FastAPI server     |
| Frontend | localhost:5173 | Vite HMR         | IDE application    |
| Docs     | localhost:4321 | Astro dev server | Documentation site |

### Starting Development

```bash
make dev    # Start all services with hot reload
make logs   # View logs from all services
make down   # Stop all services
```

### Rebuilding Services

If you change Dockerfiles or dependencies, rebuild services with:

```bash
make dev  # Automatically rebuilds changed services
```

### Volume Mounts

All services use volume mounts for live code editing:

- `./api` → `/app` (backend)
- `./frontend` → `/app` (frontend & docs)
- `./hardcaml` → `/hardcaml` (all services)

Changes to source files are immediately reflected in running containers.

## Testing

All tests run inside Docker containers. Start the development services first:

```bash
make dev          # Start services (required for tests)
make test         # Run all tests (~30s)
make test-dune    # OCaml examples via dune (~5s)
make test-api     # API integration tests (~25s)
```

| Tier | Command          | What it tests                               |
| ---- | ---------------- | ------------------------------------------- |
| Dune | `make test-dune` | OCaml code via `compiler.compile_and_run()` |
| API  | `make test-api`  | Full API flow via TestClient                |

Tests execute in the running `backend` container, so the development services must be running.

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

Uses [uv](https://docs.astral.sh/uv/) for dependency management.
Dependencies are automatically installed when you start the development services with `make dev`.
The backend service installs dependencies in the container's virtual environment at `/opt/venv` on startup.

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

## Building and Pushing Docker Images

The project uses pre-built base images from GitHub Container Registry. To build and push your own images:

```bash
# Build images locally
make build-base    # Base image with OCaml toolchain
make build-prod    # Production app image
make build-docs    # Production docs image

# Push to GitHub Container Registry
make push-base     # Push base image
make push-prod     # Push production app image
make push-docs     # Push docs image

make push-all      # Build and push all images
```

Images are tagged as `ghcr.io/<GITHUB_USERNAME>/<image-name>:latest`.
Set `GITHUB_USERNAME` in your `.env` file to specify your GitHub username for image tagging.

## Deployment

See [DEPLOY.md](DEPLOY.md) for Railway setup.

## Environment Variables

Copy `.env.example` to `.env` and configure:

- `RATE_LIMIT_PER_MINUTE`: API rate limit (default: 10)
- `VITE_PUBLIC_POSTHOG_KEY`: PostHog API key (optional, for analytics)
- `VITE_PUBLIC_POSTHOG_HOST`: PostHog host URL (optional)
- `VITE_POSTHOG_ENABLED`: Enable/disable analytics (optional)
- `GITHUB_USERNAME`: Only needed if building/pushing your own images (defaults to `treygilliland`)
- `BASE_IMAGE`: Base image with OCaml toolchain (defaults to `ghcr.io/treygilliland/hardcaml-base:latest`)
- `PROD_IMAGE`: Production app image (defaults to `ghcr.io/treygilliland/hardcaml-web-ide:latest`)
- `DOCS_IMAGE`: Docs site image (defaults to `ghcr.io/treygilliland/hardcaml-docs:latest`)

**Note:** Docker images are publicly available at `ghcr.io/treygilliland/`, so you can use them directly without configuration.

See `.env.example` for all available options.
