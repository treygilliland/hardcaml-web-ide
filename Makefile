.PHONY: base dev up build build-dev build-prod build-all down logs clean

build-base:
	docker build -f Dockerfile.base -t hardcaml-base .

dev: base
	docker compose -f docker-compose.dev.yml up --build

up: base
	docker compose up --build

build-dev: base
	docker compose -f docker-compose.dev.yml build

build-prod: base
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
