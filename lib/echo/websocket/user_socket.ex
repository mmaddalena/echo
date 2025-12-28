defmodule Echo.WS.UserSocket do
  @behaviour :cowboy_websocket

  require Logger

  # Handshake inicial. Decide si este proceso en HTTP se convierte a WS
  @impl true
  def init(req, _opts) do
    case extract_token(req) do
      {:ok, token} ->
        case Auth.verify_token(token) do
          {:ok, user_id} ->
            state = %{
              user_id: user_id,
              user_session: nil,
              token: token,
              authenticated: true
            }

            {:cowboy_websocket, req, state, %{idle_timeout: 300_000}}

          {:error, :token_expired} ->
            Logger.warn("Token expired for WebSocket connection")
            {:reply, {:close, 1008, "Token expired"}, req, %{}}

          {:error, _reason} ->
            Logger.warn("Invalid token for WebSocket connection")
            {:reply, {:close, 1008, "Unauthorized"}, req, %{}}
        end

      :error ->
        Logger.warn("Missing token for WebSocket connection")
        {:reply, {:close, 1008, "Token missing"}, req, %{}}
    end
  end

  # Cowboy llama a este init porque el otro init autorizó el upgrade
  # El proceso YA es un WS (sería equivalente a GenServer.init)
  @impl true
  def websocket_init(state) do
    {:ok, us_pid} = Echo.Users.UserSessionSup.get_or_start(state.user_id)

    Echo.Users.UserSession.attach_socket(us_pid, self())

    {:ok, %{state | user_session: us_pid}}
  end

  # Mensajes que llegan DESDE el cliente
  @impl true
  def websocket_handle({:text, raw}, state) do
    case Jason.decode(raw) do
      {:ok, msg} ->
        dispatch(msg, state)

      _ ->
        {:ok, state}
    end
  end

  # Mensajes que llegan DESDE el backend (OTP)
  # El :reply hace que Cowboy le mande el segundo arg al Cliente
  @impl true
  def websocket_info({:send, payload}, state) do
    {:reply, {:text, Jason.encode!(payload)}, state}
  end

  @impl true
  def websocket_info(_msg, state) do
    {:ok, state}
  end

  # Dispatch de mensajes del cliente
  defp dispatch(%{"type" => "open_chat", "chat_id" => chat}, state) do
    Echo.Users.UserSession.open_chat(state.user_session, chat)
    {:ok, state}
  end

  defp dispatch(%{"type" => "send_message", "chat_id" => chat, "text" => text}, state) do
    Echo.Users.UserSession.send_message(state.user_session, chat, text)
    {:ok, state}
  end

  defp dispatch(_unknown, state) do
    {:ok, state}
  end

  # Helper
  defp extract_token(req) do
    # 1. Intentar obtener de query params
    qs = :cowboy_req.parse_qs(req)

    case List.keyfind(qs, "token", 0) do
      {_, token} ->
        {:ok, token}

      nil ->
        # 2. Intentar obtener de headers Authorization: Bearer
        headers = :cowboy_req.headers(req)

        case :proplists.get_value("authorization", headers) do
          "Bearer " <> token ->
            {:ok, String.trim(token)}

          _ ->
            # 3. Intentar obtener de cookies
            cookies = :cowboy_req.parse_cookies(req)

            case List.keyfind(cookies, "token", 0) do
              {_, token} -> {:ok, token}
              nil -> :error
            end
        end
    end
  end
end
