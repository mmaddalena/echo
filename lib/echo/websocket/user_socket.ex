defmodule Echo.WS.UserSocket do
  @behaviour :cowboy_websocket

  require Logger

  # Handshake inicial. Decide si este proceso en HTTP se convierte a WS
  @impl true
  def init(req, _opts) do
    case extract_token(req) do
      {:ok, token} ->
        case Echo.Auth.Auth.verify_token(token) do
          {:ok, user_id} ->
            state = %{
              user_id: user_id,
              user_session: nil
            }

            # Autorizamos el upgrade a WS.
            {:cowboy_websocket, req, state}

          _ ->
            # No autorizamos el upgrade
            {:reply, {:close, 4001, "unauthorized"}, req, %{}}
        end

      :error ->
        {:reply, {:close, 4001, "token missing"}, req, %{}}
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
    Echo.Users.UserSession.send_msg(state.user_session, chat, text)
    {:ok, state}
  end

  defp dispatch(_unknown, state) do
    {:ok, state}
  end

  # Helper
  defp extract_token(req) do
    case :cowboy_req.parse_qs(req) do
      qs ->
        case List.keyfind(qs, "token", 0) do
          {_, token} -> {:ok, token}
          nil -> :error
        end
    end
  end
end
