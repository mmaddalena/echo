FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app
ENV MIX_ENV=prod

# ---------- SOURCE ----------
COPY . .

# ---------- GCP ----------
RUN mkdir -p /app/priv/gcp

# ---------- ELIXIR ----------
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

# ---------- FRONTEND ----------
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# ---------- STATIC ----------
WORKDIR /app
RUN mkdir -p priv/static \
 && cp -r frontend/dist/* priv/static/ \
 && ls -lah priv/static

# ---------- COMPILE ----------
RUN mix compile

CMD ["mix", "run", "--no-halt"]
