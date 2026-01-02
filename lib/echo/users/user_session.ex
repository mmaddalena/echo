defmodule Echo.Users.UserSession do
  @moduledoc """
  Es un genserver que maneja toda la sesion del usuario.
  Se crea cuando el usuario se logea, y vive hasta que se logoutea o
  hasta que pase x tiempo de inactividad.


  En su estado guarda cosas de rápido y frecuente acceso como:
  id del usuario,
  últimos n mensajes,
  last activity,
  last_chat_opened_id
  texto escrito pero no mandado (en borrador)
    (este no deberia estar aca, porque un usuario podria tener un borrador en mas de un chat igual)
  """

  use GenServer

  def start_link(user_id) do
    GenServer.start_link(
      __MODULE__,
      user_id,
      name: {:via, Registry, {Echo.ProcessRegistry, {:user, user_id}}}
    )
  end

  ##### Funciones llamadas desde el socket

  def attach_socket(us_pid, socket_pid) do
    GenServer.cast(us_pid, {:attach_socket, socket_pid})
  end

  def open_chat(us_pid, chat_id) do
    GenServer.cast(us_pid, {:open_chat, chat_id})
  end

  def send_message(us_pid, chat_id, text) do
    GenServer.cast(us_pid, {:send_message, %{chat_id: chat_id, text: text}})
  end

  ##### Funciones llamadas desde el dominio

  def message_sent(us_pid, msg) do
    GenServer.cast(us_pid, {:message_sent, msg})
  end

  def receive_message(us_pid, msg) do
    GenServer.cast(us_pid, {:receive_message, msg})
  end

  ##### Callbacks

  @impl true
  def init(user_id) do
    user = Echo.Users.User.get(user_id)

    state = %{
      user_id: user_id,
      user: user,
      socket: nil,
      current_chat_id: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:attach_socket, socket_pid}, state) do
    Process.link(socket_pid)

    user_info = %{
      user_id: state.user_id,
      user: state.user,
      current_chat_id: state.current_chat_id
      # TODO: Faltan los n últimos chats, para listárselos
    }

    # Le mandamos el state inicial al front D1
    send(state.socket, {:send, {:user_info, user_info}})
    {:noreply, %{state | socket: socket_pid}}
  end

  @impl true
  def handle_cast({:open_chat, chat_id}, state) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(chat_id)
    {:ok, chat_info} = Echo.Chats.ChatSession.open_chat(cs_pid)
    # asumimos que chat_info es un map
    send(state.socket, {:send, {:chat_info, chat_info}})
    # TODO: ACTUALIZAR LAST ACTIVITY
    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:send_message, %{chat_id: chat_id, client_msg_id: client_msg_id, text: text}},
        state
      ) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(chat_id)
    Echo.Chats.ChatSession.send_message(cs_pid, state.user_id, client_msg_id, text)
    # TODO: ACTUALIZAR LAST ACTIVITY
    {:noreply, state}
  end

  @impl true
  def handle_cast({:message_sent, msg}, state) do
    # msg contiene el client_msg_id
    send(state.socket, {:send, {:message_sent, msg}})
    # TODO: ACTUALIZAR LAST ACTIVITY
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    # cleanup (habria que ver bien qué hay que limpiar)
    :ok
  end
end
