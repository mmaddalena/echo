.PHONY: dev db stop deps run build test

dev:
	iex -S mix
shell:
	docker compose run --rm app sh
iex:
	docker compose run --service-ports --remove-orphans app iex -S mix

up:
	docker compose up -d db
build:
	docker compose build app
setup:
	docker compose run --rm app mix ecto.setup
reset:
	docker compose run --rm app mix ecto.reset
seed:
	docker compose run --rm app mix run priv/repo/seeds/seeds.exs
run: 
	docker compose up app
stop:
	docker compose down -v

deps-local:
	mix deps.get
compile-local:
	mix compile
run-local:
	mix run --no-halts

test:
	docker compose up -d db
	@timeout /t 3 > NUL 2>&1 || sleep 3
	docker compose run test mix deps.get
	docker compose run test