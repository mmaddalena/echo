defmodule Echo.Chats.ChatSession do
  alias Echo.Users.UserSessionSup
  alias Echo.Chats.ChatSessionSup
  # Idem que el UserSession.
  # Es un Genserver que vive mientras la sesion del chat esté viva.
  # La sesión vive despues de x tiempo de inactividad.
  use GenServer
  alias Echo.Chats.Chat
  alias Echo.Users.User
  alias Echo.Users.UserSession
  alias Echo.Constants

  def start_link(chat_id) do
    GenServer.start_link(
      __MODULE__,
      chat_id,
      name: {:via, Registry, {Echo.ProcessRegistry, {:chat, chat_id}}}
    )
  end

  ##### Funciones llamadas desde el dominio

  def get_chat_info(cs_pid, user_id, us_pid) do
    GenServer.cast(cs_pid, {:chat_info, user_id, us_pid})
  end

  def send_message(chat_session_pid, user_id, client_msg_id, body) do
    # Itera en cada user_id de los miembros del chat...
    # Creeria que crea un struct message del tipo del schema Message
    # Esta funcion la llama el userSession del emisor, viniendo del socket, desde el cliente.
    # Le llama al userSession.message.sent(message) del emisor. (message es un map con la info del msg (que también contiene el client_msg_id)))
    # Se fija si esta la usersession viva:
    # Si sí: le llama a userSession.recieve_message (ACA NO MANDA EL client_msg_id, porque los receptores no lo necesitan)
    # Si no: crea una notificacion para ese usuario y lo persiste.
  end


  ##### Callbacks

  @impl true
  def init(chat_id) do
    state = %{
      chat_id: chat_id,
      chat: Chat.get(chat_id),
      last_messages: Chat.get_last_messages(chat_id),
      members: Chat.get_members(chat_id)
    }
    {:ok, state}
  end

  @impl true
  def handle_cast({:chat_info, user_id, us_pid}, state) do
    is_private? = state.chat.type == Constants.private_chat()
    other_user_id = Chat.get_other_user_id(state.chat_id, user_id)

    status =
      case is_private? do
        true -> if User.is_active?(other_user_id), do: Constants.online(), else: Constants.offline()
        false -> nil
      end

    senders_ids =
      state.last_messages
      |> Enum.map(& &1.sender_user_id)
      |> Enum.uniq()
    senders = case is_private? do
      true -> %{}
      false -> User.get_usable_names(user_id, senders_ids)
    end

    messages =
      Enum.map(state.last_messages, fn message ->
        type =
          if message.sender_user_id == user_id,
            do: Constants.outgoing(),
            else: Constants.incoming()

        sender_name = Map.get(senders, message.sender_user_id)

        message
        |> Map.put(:type, type)
        |> Map.put(:sender_name, sender_name)
      end)

    name = User.get_usable_name(user_id, other_user_id, state.chat.name)

    avatar_url = Chat.get_avatar_url(state.chat, other_user_id)

    chat_info = %{
      type: "chat_info",
      chat: %{
        id: state.chat_id,
        messages: messages,
        name: name,
        status: status,
        avatar_url: avatar_url
      }
    }

    UserSession.send_chat_info(us_pid, chat_info)

    {:noreply, state}
  end





end
