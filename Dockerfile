# Hardcaml Web IDE - Production Dockerfile
# Uses pre-built base image from ghcr.io/treygilliland (publicly available)
#
# Usage:
#   docker build -t hardcaml-web-ide .
#   docker build --build-arg BASE_IMAGE=other/image:tag -t hardcaml-web-ide .

ARG BASE_IMAGE=ghcr.io/treygilliland/hardcaml-base:latest
FROM ${BASE_IMAGE} AS base

# Install uv and Python deps
RUN curl -LsSf https://astral.sh/uv/0.9.24/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
COPY api/pyproject.toml api/uv.lock /app/
RUN cd /app && uv sync --frozen

# --- Frontend build stage ---
FROM node:24-alpine AS frontend-builder

RUN npm install -g pnpm

WORKDIR /app
COPY frontend/package.json frontend/pnpm-workspace.yaml frontend/pnpm-lock.yaml ./
COPY frontend/ui/package.json ./ui/
COPY frontend/ide/package.json ./ide/
RUN pnpm install --frozen-lockfile

COPY frontend/tsconfig.base.json ./
COPY frontend/ui/ ./ui/
COPY frontend/ide/ ./ide/
COPY hardcaml/ /hardcaml/

WORKDIR /app/ide
RUN pnpm build

# --- Development stage ---
FROM base AS dev

# Copy API code (will be overridden by volume mount in dev)
COPY api/ /app/

WORKDIR /app
EXPOSE 8000

CMD ["sh", "-c", "uv run uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --reload"]

# --- Production stage ---
FROM base AS prod

# Copy API code
COPY api/ /app/

# Copy built frontend
COPY --from=frontend-builder /app/ide/dist /app/static

WORKDIR /app
EXPOSE 8000

CMD ["sh", "-c", "uv run uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
