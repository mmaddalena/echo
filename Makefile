.PHONY: dev db stop
dev:
	iex -S mix
up:
	docker compose up -d
deps:
	mix deps.get
setup:
	mix ecto.setup
run:
	mix run --no-halt
stop:
	docker compose down
seed_users:
	mix run priv/repo/seeds/seed_usuarios.exs