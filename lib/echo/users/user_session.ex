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
    GenServer.start_link(__MODULE__, %{user_id: user_id})
  end

  def attach_socket(us_pid, socket_pid) do
    GenServer.cast(us_pid, {:attach_socket, socket_pid})
  end

  def open_chat(us_pid, chat_id) do
    GenServer.cast(us_pid, {:open_chat, chat_id})
  end

  def send_msg(us_pid, chat_id, text) do
    GenServer.cast(us_pid, {:send_msg, %{chat_id: chat_id, text: text}})
  end

  def receive_message(us_pid, msg) do
    GenServer.cast(us_pid, {:receive_message, msg})
  end






  ##### Callbacks

  @impl true
  def init(user_id) do
    state = %{
      user_id: user_id,
      socket: nil
    }
    {:ok, state}
  end


  @impl true
  def handle_cast({:attach_socket, socket_pid}, state) do
    Process.link(socket_pid)
    {:noreply, %{state | socket: socket_pid}}
  end

  @impl true
  def handle_cast({:open_chat, chat_id}, state) do
    {:ok, cs_pid} = Echo.Chats.ChatSessionSup.get_or_start(chat_id)
    {:ok, chat_info} = Echo.Chats.ChatSession.open_chat(cs_pid)
    send(state.socket, {:send, chat_info}) # TODO asumimos que chat_info es un map
    {:noreply, state} # TODO: ACTUALIZAR LAST ACTIVITY
  end

  @impl true
  def handle_info({:ws_msg, payload}, state) do
    # Mensaje entrante del socket.
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    # cleanup (habria que ver bien qué hay que limpiar)
    :ok
  end
end
