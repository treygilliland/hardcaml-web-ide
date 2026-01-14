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
make up       # Start production services (service :8000, docs :8080)
make down     # Stop all services
make logs     # View logs from all services
make clean    # Stop services and remove volumes
```

## What do you want to do?

- **Use the Web IDE locally**: run `make dev`, then open the IDE on `localhost:5173`.
- **Work on the backend compile API / test runner**: see [`api/README.md`](api/README.md).
- **Write OCaml/Hardcaml circuits and run dune tests directly**: see [`hardcaml/README.md`](hardcaml/README.md).
- **Work on the frontend**: see [`frontend/README.md`](frontend/README.md).
- **Deploy**: see [`docs/DEPLOY.md`](docs/DEPLOY.md).

## Project Structure

```
├── api/                  		# FastAPI compilation and server backend (see api/README.md)
├── frontend/             		# pnpm workspace (see frontend/README.md)
│   ├── ui/               		#   @hardcaml/ui    - shared components
│   ├── ide/              		#   @hardcaml/ide   - main IDE app
│   └── docs/             		#   @hardcaml/docs  - Astro docs site
├── hardcaml/             		# hardcaml source code (see hardcaml/README.md)
│   ├── examples/         		#   Example circuits
│   ├── aoc/              		#   Advent of Code solutions
│   ├── n2t/              		#   Nand2Tetris solutions and stubs for exercises
│   ├── build-templates/ 		  # Dune project templates
│   └── build-cache/      		# Pre-built dune project
```

## Architecture

The project is split into:

1. **Python FastAPI Backend** (`api/`) - Compiles and runs Hardcaml circuits, serves the IDE app in production
2. **Frontend Workspace** (`frontend/`) - pnpm monorepo containing:
   - `@hardcaml/ui` - Shared React components, hooks, and API client
   - `@hardcaml/ide` - Main IDE application (React + Vite)
   - `@hardcaml/docs` - Documentation site (Astro Starlight)

The frontend uses a pnpm workspace to share code between the IDE and docs site.
The IDE app is bundled with the API in production, while the docs site runs as a separate service in both development and production.

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

### Docker Configuration

```
├── Dockerfile            		# App image (uses base)
├── Dockerfile.base       		# Base image (OCaml toolchain)
├── docker-compose.yml    		# Production services
├── docker-compose.dev.yml    # Development services
├── frontend/
│   ├── Dockerfile.docs         # Docs site image
│   └── Dockerfile.frontend.dev # Frontend dev image
└── railway.json                # Railway deployment config
```

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

## Configuration

- **Environment variables**: see `.env.example` (rate limiting, analytics, image names, etc.).
- **Deployment**: see [`docs/DEPLOY.md`](docs/DEPLOY.md).
