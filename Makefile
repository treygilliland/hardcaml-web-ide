.PHONY: dev up down logs clean test test-dune test-api build-base-local

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

# Build base image locally (GitHub Actions handles this automatically)
build-base-local:
	docker build -f Dockerfile.base -t ghcr.io/treygilliland/hardcaml-base:latest .
