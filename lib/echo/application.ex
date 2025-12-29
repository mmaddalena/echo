defmodule Echo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    children = [
      # Ecto
      Echo.Repo,

      # Registries
      {Registry, keys: :unique, name: Echo.UserSessionRegistry},
      {Registry, keys: :unique, name: Echo.ChatSessionRegistry},

      # Dynamic Supervisors
      Echo.Users.UserSessionSup,
      Echo.Chats.ChatSessionSup,

      # Cowboy Server HTTP + WebSocket

      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Echo.Http.Router,
        options: [
          port: 4000,
        ]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
