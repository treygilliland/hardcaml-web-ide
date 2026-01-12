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

# Build base image locally (amd64 only, for Railway)
build-base:
	docker build -f Dockerfile.base -t $(BASE_IMAGE) --platform linux/amd64 .

# Build production image locally (amd64 only, for Railway)
build-prod:
	docker build -f Dockerfile --target prod --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(PROD_IMAGE) --platform linux/amd64 .

# Build docs image locally (amd64 only, for Railway)
build-docs:
	docker build -f frontend/Dockerfile.docs -t $(DOCS_IMAGE) --platform linux/amd64 .

# Push base image to GHCR
push-base: build-base
	docker push $(BASE_IMAGE)

# Push production image to GHCR
push-prod: build-prod
	docker push $(PROD_IMAGE)

# Push docs image to GHCR
push-docs: build-docs
	docker push $(DOCS_IMAGE)

# Build and push all images
push-all: push-base push-prod push-docs

# Docs commands
docs:
	cd frontend && npx pnpm --filter @hardcaml/docs build

docs-dev:
	cd frontend && npx pnpm --filter @hardcaml/docs dev
