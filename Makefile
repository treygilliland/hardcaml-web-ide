.PHONY: build-base dev up build build-dev build-prod build-all down logs clean test test-dune test-api

build-base:
	docker build -f Dockerfile.base -t hardcaml-base .

dev: build-base
	docker compose -f docker-compose.dev.yml up --build

up: build-base
	docker compose up --build

build-dev: build-base
	docker compose -f docker-compose.dev.yml build

build-prod: build-base
	docker compose build

build: build-base build-dev build-prod

down:
	docker compose -f docker-compose.dev.yml down
	docker compose down

logs:
	docker compose -f docker-compose.dev.yml logs -f

clean:
	docker compose -f docker-compose.dev.yml down -v
	docker compose down -v

# Testing
test: test-dune test-api

test-dune:
	@echo "Running dune tests inside Docker..."
	docker compose -f docker-compose.dev.yml exec -T backend uv run python test_runner.py

test-api:
	@echo "Running API integration tests..."
	docker compose -f docker-compose.dev.yml exec -T backend uv run --extra test pytest tests/ -v --tb=short
