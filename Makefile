.PHONY: base dev up build down logs clean

base:
	docker build -f Dockerfile.base -t hardcaml-base .

dev: base
	docker compose -f docker-compose.dev.yml up --build

up: base
	docker compose up --build

build: base
	docker compose build

down:
	docker compose down

logs:
	docker compose -f docker-compose.dev.yml logs -f

clean:
	docker compose -f docker-compose.dev.yml down -v
	docker compose down -v
