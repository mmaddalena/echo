defmodule Echo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Configurar las rutas para HTTP y WebSocket
    dispatch =
      :cowboy_router.compile([
        {:_,
         [
           {"/ws", Echo.Websocket.UserSocket, []},
           {:_, Plug.Cowboy.Handler, {Echo.Router, []}}
         ]}
      ])

    children = [
      # Ecto
      Echo.Repo,

      # Registries
      {Registry, keys: :unique, name: Echo.UserSessionRegistry},
      {Registry, keys: :unique, name: Echo.ChatSessionRegistry},

      # Dynamic Supervisors
      Echo.Users.UserSessionSup,
      Echo.Users.ChatSessionSup,

      # Cowboy Server HTTP + WebSocket
      {
        :cowboy_clear,
        %{
          id: :http,
          port: 4000,
          dispatch: dispatch
        }
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
