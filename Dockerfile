# Hardcaml Web IDE - Production Dockerfile
# Uses pre-built base image from ghcr.io (default: ghcr.io/treygilliland/hardcaml-base:latest)
#
# Usage:
#   docker build -t hardcaml-web-ide .
#   docker build --build-arg BASE_IMAGE=other/image:tag -t hardcaml-web-ide .

ARG BASE_IMAGE=ghcr.io/treygilliland/hardcaml-base:latest
FROM ${BASE_IMAGE} AS base

# --- Frontend build stage ---
FROM node:24-alpine AS frontend-builder

WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
COPY hardcaml/ ./hardcaml/
RUN npm run build

# --- Development stage ---
FROM base AS dev

# Copy API code (will be overridden by volume mount in dev)
COPY api/ /app/

WORKDIR /app
EXPOSE 8000

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# --- Production stage ---
FROM base AS prod

# Copy API code
COPY api/ /app/

# Copy built frontend
COPY --from=frontend-builder /frontend/dist /app/static

WORKDIR /app
EXPOSE 8000

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
