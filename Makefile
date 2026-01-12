.PHONY: dev db stop
dev:
	iex -S mix
up:
	docker compose up -d db
build:
	docker compose build
setup:
	docker compose run --rm app mix ecto.setup
reset:
	docker compose run --rm app mix ecto.reset
seed:
	docker compose run --rm app mix run priv/repo/seeds/seeds.exs
run:
	docker compose up app
shell:
	docker compose run --rm app sh
stop:
	docker compose down -v