import Config

config :echo, Echo.Repo,
  database: "echo_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :echo, ecto_repos: [Echo.Repo]

# Configuración JWT
config :joken,
  default_signer: "dev_secret_change_this_in_production_min_32_chars_long_please"

config :echo,
  jwt_secret_key:
    System.get_env("JWT_SECRET_KEY") || "default_dev_secret_change_in_production_min_32_chars"

# Si quieres configurar tiempo de expiración:
config :echo,
  jwt_expiration_hours: 24

# Configuración de BCrypt
# config :bcrypt_elixir, log_rounds: 12
