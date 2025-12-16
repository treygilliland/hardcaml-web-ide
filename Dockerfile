# Hardcaml Web IDE - Production image
# Requires: docker build -f Dockerfile.base -t hardcaml-base .

# --- Frontend build stage ---
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# --- Runtime stage ---
ARG BASE_IMAGE=hardcaml-base
FROM ${BASE_IMAGE}

# Copy and pre-build template project
COPY template/ /opt/template/
RUN cd /opt/template && dune build @runtest --force 2>/dev/null || true

# Install Python dependencies
COPY api/requirements.txt /app/requirements.txt
RUN pip3 install --break-system-packages -r /app/requirements.txt

# Copy API code
COPY api/ /app/

# Copy built frontend
COPY --from=frontend-builder /frontend/dist /app/static

WORKDIR /app

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
