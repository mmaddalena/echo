FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

ENV MIX_ENV=prod
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/priv/gcp/service-account.json

# ---------- APP SOURCE ----------
COPY . .

# ---------- GCP ----------
RUN mkdir -p /app/priv/gcp

# ---------- ELIXIR DEPS ----------
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

# ---------- FRONTEND ----------
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# ---------- STATIC FILES ----------
WORKDIR /app
RUN mkdir -p priv/static \
 && cp -r frontend/dist/* priv/static/ \
 && test -f priv/static/index.html

# ---------- COMPILE ----------
RUN mix compile

# ---------- START ----------
CMD sh -c '\
  if [ -n "$GCP_SERVICE_ACCOUNT_JSON" ]; then \
    printf "%s" "$GCP_SERVICE_ACCOUNT_JSON" > /app/priv/gcp/service-account.json; \
  fi && \
  mix run --no-halt'
