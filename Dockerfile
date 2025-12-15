# Hardcaml Web IDE - Docker image with OxCaml 5.2 + Hardcaml toolchain
# Based on setup from aoc/fpga/README.md, adapted for Ubuntu Linux

# --- Frontend build stage ---
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# --- OCaml build stage ---
FROM ubuntu:24.04 AS ocaml-base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for OCaml/opam and its packages
RUN apt-get update && apt-get install -y \
    opam \
    build-essential \
    pkg-config \
    libgmp-dev \
    libffi-dev \
    m4 \
    git \
    curl \
    ca-certificates \
    autoconf \
    zlib1g-dev \
    libssl-dev \
    libev-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Initialize opam (disable sandboxing for Docker)
RUN opam init --disable-sandboxing --bare -y

# Install OxCaml switch (same as Mac setup, adapted for Linux)
# This step takes a while as it builds the compiler
RUN opam update --all && \
    opam switch create 5.2.0+ox \
      --repos ox=git+https://github.com/oxcaml/opam-repository.git,default

# Install Hardcaml and all dependencies
# This is the same package set as the Mac setup in README.md
RUN eval $(opam env --switch 5.2.0+ox) && \
    opam install -y \
      hardcaml \
      hardcaml_waveterm \
      hardcaml_test_harness \
      ppx_hardcaml \
      core \
      core_unix \
      ppx_jane \
      dune \
      re \
      rope

# Copy and pre-build template project to cache compiled dependencies
COPY template/ /opt/template/
RUN eval $(opam env --switch 5.2.0+ox) && \
    cd /opt/template && dune build 2>/dev/null || true

# --- Runtime stage ---
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Copy opam environment from build stage (includes all compiled packages)
COPY --from=ocaml-base /root/.opam /root/.opam

# Copy pre-built template
COPY --from=ocaml-base /opt/template /opt/template

# Install runtime dependencies + Python for API
# Note: We need dev packages because we compile user code at runtime
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libgmp-dev \
    libffi-dev \
    zlib1g-dev \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up opam environment variables
ENV OPAM_SWITCH_PREFIX=/root/.opam/5.2.0+ox
ENV CAML_LD_LIBRARY_PATH=/root/.opam/5.2.0+ox/lib/stublibs:/root/.opam/5.2.0+ox/lib/ocaml/stublibs:/root/.opam/5.2.0+ox/lib/ocaml
ENV OCAML_TOPLEVEL_PATH=/root/.opam/5.2.0+ox/lib/toplevel
ENV PATH=/root/.opam/5.2.0+ox/bin:$PATH

# Install Python dependencies
COPY api/requirements.txt /app/requirements.txt
RUN pip3 install --break-system-packages -r /app/requirements.txt

# Copy API code
COPY api/ /app/

# Copy built frontend from frontend-builder stage
COPY --from=frontend-builder /frontend/dist /app/static

WORKDIR /app

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
