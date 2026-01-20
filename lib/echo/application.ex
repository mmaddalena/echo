defmodule Echo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    dispatch =
      :cowboy_router.compile([
        {:_, [
          {"/ws", Echo.WS.UserSocket, []},
          {:_, Plug.Cowboy.Handler, {Echo.Http.Router, []}}
        ]}
    ])

    children = [
      {Goth, name: Echo.Goth},
      Echo.Repo,
      Echo.ProcessRegistry,
      Echo.Users.UserSessionSup,
      Echo.Chats.ChatSessionSup,

      %{
        id: :http_listener,
        start: {
          :cowboy,
          :start_clear,
          [
            :http_listener,
            [port: 4000],
            %{env: %{dispatch: dispatch}}
          ]
        }
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Echo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
