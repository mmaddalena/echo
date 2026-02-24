FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

ENV MIX_ENV=prod
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/priv/gcp/service-account.json

# ---------- APP SOURCE ----------
COPY . .

# Create directories for both GCP credentials and local storage
RUN mkdir -p /app/priv/gcp && \
    mkdir -p /app/priv/uploads && \
    mkdir -p /app/priv/uploads/avatars/users && \
    mkdir -p /app/priv/uploads/avatars/groups && \
    mkdir -p /app/priv/uploads/avatars/register && \
    mkdir -p /app/priv/uploads/chat && \
    chmod -R 755 /app/priv/uploads

# ---------- ELIXIR DEPS ----------
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

# ---------- COMPILE ----------
RUN mix compile

# ---------- START ----------
CMD sh -c '\
  if [ -n "$GCP_SERVICE_ACCOUNT_JSON" ]; then \
    printf "%s" "$GCP_SERVICE_ACCOUNT_JSON" > /app/priv/gcp/service-account.json; \
    echo "GCP configured with service account from env"; \
  else \
    echo "No GCP credentials found, using local storage at /app/priv/uploads"; \
  fi && \
  mix run --no-halt'