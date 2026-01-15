.PHONY: dev up down logs clean test test-dune test-api build-base build-prod build-docs push-base push-prod push-docs push-all docs docs-dev

dev:
	docker compose -f docker-compose.dev.yml up --build

up:
	docker compose up --build

down:
	docker compose -f docker-compose.dev.yml down
	docker compose down

logs:
	docker compose -f docker-compose.dev.yml logs -f

clean:
	docker compose -f docker-compose.dev.yml down -v
	docker compose down -v

test: test-dune test-api

test-dune:
	docker compose -f docker-compose.dev.yml exec -T backend uv run python test_runner.py

test-api:
	docker compose -f docker-compose.dev.yml exec -T backend uv run --extra test pytest tests/ -v --tb=short


# Docs commands
docs:
	cd frontend && npx pnpm --filter @hardcaml/docs build

docs-dev:
	cd frontend && npx pnpm --filter @hardcaml/docs dev

#####
# DOCKER COMMANDS
#####

# Load environment variables from .env file if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Default values if not set in .env
# Public images are available at ghcr.io/treygilliland/
GITHUB_USERNAME ?= treygilliland
BASE_IMAGE ?= ghcr.io/$(GITHUB_USERNAME)/hardcaml-base:latest
PROD_IMAGE ?= ghcr.io/$(GITHUB_USERNAME)/hardcaml-web-ide:latest
DOCS_IMAGE ?= ghcr.io/$(GITHUB_USERNAME)/hardcaml-docs:latest

# Detect native platform
NATIVE_PLATFORM := $(shell uname -m | sed 's/x86_64/linux\/amd64/' | sed 's/arm64/linux\/arm64/' | sed 's/aarch64/linux\/arm64/')

# Build base image for local dev (native architecture - fast on Mac M1/M2)
build-base-local:
	docker build -f Dockerfile.backend.base -t $(BASE_IMAGE) .

# Build base image for production (amd64 only, for Railway)
build-base:
	docker build -f Dockerfile.backend.base -t $(BASE_IMAGE) --platform linux/amd64 .

# Build and push multi-platform base image (requires: docker buildx create --use)
build-base-multi:
	docker buildx build -f Dockerfile.backend.base \
		--platform linux/amd64,linux/arm64 \
		-t $(BASE_IMAGE) \
		--push .

# Build production image for local dev (native architecture)
build-prod-local:
	docker build -f Dockerfile.backend --target prod --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PROD_IMAGE) .

# Build production image for deployment (amd64 only, for Railway)
build-prod:
	docker build -f Dockerfile.backend --target prod --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PROD_IMAGE) --platform linux/amd64 .

# Build and push multi-platform production image
build-prod-multi:
	docker buildx build -f Dockerfile.backend --target prod \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--platform linux/amd64,linux/arm64 \
		-t $(PROD_IMAGE) \
		--push .

# Build docs image for local dev (native architecture)
build-docs-local:
	docker build -f frontend/Dockerfile.frontend -t $(DOCS_IMAGE) .

# Build docs image for deployment (amd64 only, for Railway)
build-docs:
	docker build -f frontend/Dockerfile.frontend -t $(DOCS_IMAGE) --platform linux/amd64 .

# Push base image to GHCR (single platform)
push-base: build-base
	docker push $(BASE_IMAGE)

# Push production image to GHCR (single platform)
push-prod: build-prod
	docker push $(PROD_IMAGE)

# Push docs image to GHCR (single platform)
push-docs: build-docs
	docker push $(DOCS_IMAGE)

# Build and push all images (single platform - amd64)
push-all: push-base push-prod push-docs

# Build and push all multi-platform images (recommended for shared registries)
push-all-multi: build-base-multi build-prod-multi

