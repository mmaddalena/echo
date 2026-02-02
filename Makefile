.PHONY: dev db stop deps run build
dev:
	iex -S mix
up:
	docker compose up -d db
build:
	docker compose build app
setup:
	docker compose run --rm app mix ecto.setup
reset:
	docker compose run --rm app mix ecto.reset
deps:
	docker compose run --rm app mix deps.get
seed:
	docker compose run --rm app mix run priv/repo/seeds/seeds.exs
run: build
	docker compose up app
shell:
	docker compose run --rm app sh
stop:
	docker compose down -v

deps-local:
	mix deps.get
compile-local:
	mix compile
run-local:
	mix run --no-halts