.PHONY: dev db stop
dev:
	iex -S mix
up:
	docker compose up -d db
build:
	docker compose build
deps:
	mix deps.get
setup:
	docker compose run --rm app mix ecto.setup
seed:
	docker compose run --rm app mix run priv/repo/seeds/seed_usuarios.exs
run:
	docker compose up app
shell:
	docker compose run --rm app sh
stop:
	docker compose down -v