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
├── api/                    # FastAPI backend
├── frontend/               # React + Vite
├── hardcaml/
│   ├── examples/           # Example circuits
│   └── build-cache/        # Pre-built dune project
├── Dockerfile              # App image (uses base)
├── Dockerfile.base         # Base image (OCaml toolchain)
└── .github/workflows/      # GitHub Actions (builds base image)
```

## Development

| Component | URL            | Hot Reload       |
| --------- | -------------- | ---------------- |
| Frontend  | localhost:5173 | Vite HMR         |
| API       | localhost:8000 | uvicorn --reload |

Rebuild backend after changing `Dockerfile.base`, `api/pyproject.toml`, or `hardcaml/build-cache/`:

```bash
docker compose -f docker-compose.dev.yml build backend
```

## Testing

```bash
make test        # All tests
make test-dune   # OCaml examples via dune
make test-api    # API integration tests
```

## Adding Examples

1. Create `hardcaml/examples/<name>/` with `circuit.ml`, `circuit.mli`, `test.ml`
2. Register in `frontend/src/examples/hardcaml-examples.ts`
3. Add to `api/tests/examples.py` for test coverage

## Deployment

See [DEPLOY.md](DEPLOY.md) for Railway setup.

## API

- `POST /compile` - Compile and run Hardcaml code
- `GET /health` - Health check
