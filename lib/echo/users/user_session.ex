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

  def send_user_info(us_pid) do
    GenServer.cast(us_pid, {:send_user_info})
  end

  def open_chat(us_pid, chat_id) do
    GenServer.cast(us_pid, {:open_chat, chat_id})
  end

  def send_message(us_pid, front_msg) do
    GenServer.cast(us_pid, {:send_message, front_msg})
  end

  def chat_messages_read(us_pid, chat_id) do
    GenServer.cast(us_pid, {:chat_messages_read, chat_id})
  end


  ##### Funciones llamadas desde el dominio

  def send_chat_info(us_pid, chat_info) do
    GenServer.cast(us_pid, {:send_chat_info, chat_info})
  end

  def new_message(us_pid, msg) do
    GenServer.cast(us_pid, {:new_message, msg})
  end

  def chat_read(us_pid, chat_id, reader_user_id) do
    GenServer.cast(us_pid, {:chat_read, chat_id, reader_user_id})
  end

  ##### Callbacks

  @impl true
  def init(user_id) do
    user = Echo.Users.User.get(user_id)

    state = %{
      user_id: user_id,
      user: user,
      socket: nil,
      current_chat_id: nil,
      last_activity: DateTime.utc_now()
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:attach_socket, socket_pid}, state) do
    Process.link(socket_pid)
    {:noreply, %{state | socket: socket_pid}}
  end

  @impl true
  def handle_cast({:send_user_info}, state) do
    user_info = %{
      type: "user_info",
      user: Echo.Users.User.user_payload(state.user),
      last_chats: Echo.Users.User.last_chats(state.user_id)
    }

    send(state.socket, {:send, user_info})

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end


  @impl true
  def handle_cast({:open_chat, chat_id}, state) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(chat_id)

    Echo.Chats.ChatSession.get_chat_info(cs_pid, state.user_id, self())

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end
  @impl true
  def handle_cast({:send_chat_info, chat_info}, state) do

    send(state.socket, {:send, chat_info})

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end


  @impl true
  def handle_cast({:send_message, front_msg}, state) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(front_msg["chat_id"])

    Echo.Chats.ChatSession.send_message(cs_pid, front_msg, self())

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end

  @impl true
  def handle_cast({:new_message, msg}, state) do
    send(state.socket, {:send, msg})

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end


  @impl true
  def handle_cast({:chat_messages_read, chat_id}, state) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(chat_id)

    Echo.Chats.ChatSession.chat_messages_read(cs_pid, chat_id, state.user_id)

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end

  @impl true
  def handle_cast({:chat_read, chat_id, reader_user_id}, state) do
    msg = %{
      type: "chat_read",
      chat_id: chat_id,
      reader_user_id: reader_user_id
    }
    send(state.socket, {:send, msg})

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end

  @impl true
  def terminate(_reason, state) do
    # cleanup (habria que ver bien qué hay que limpiar)
    :ok
  end



end
