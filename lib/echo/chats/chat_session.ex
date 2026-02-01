defmodule Echo.Chats.ChatSession do
  alias Echo.ProcessRegistry
  # Idem que el UserSession.
  # Es un Genserver que vive mientras la sesion del chat esté viva.
  # La sesión vive despues de x tiempo de inactividad.
  use GenServer
  alias Echo.Chats.Chat
  alias Echo.Repo
  alias Echo.Users.User
  alias Echo.Users.UserSession
  alias Echo.Messages.Messages
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

  def send_message(cs_pid, front_msg, us_pid) do
    GenServer.cast(cs_pid, {:send_message, front_msg, us_pid})
  end

  def chat_messages_read(cs_pid, chat_id, user_id) do
    GenServer.cast(cs_pid, {:chat_messages_read, chat_id, user_id})
  end

  ##### Callbacks

  @impl true
  def init(chat_id) do
    state = %{
      chat_id: chat_id,
      chat: Chat.get(chat_id),
      last_messages: Chat.get_last_messages(chat_id),
      members: Chat.get_members(chat_id),
      last_activity: DateTime.utc_now()
    }

    {:ok, %{state | last_activity: DateTime.utc_now()}}
  end

  @impl true
  def handle_cast({:chat_info, user_id, us_pid}, state) do
    is_private? = state.chat.type == Constants.private_chat()
    other_user_id = Chat.get_other_user_id(state.chat_id, user_id)

    status =
      case is_private? do
        true ->
          if User.is_active?(other_user_id), do: Constants.online(), else: Constants.offline()

        false ->
          nil
      end

    senders = get_senders(user_id, state)

    messages =
      Enum.map(state.last_messages, fn message ->
        type =
          if message.user_id == user_id,
            do: Constants.outgoing(),
            else: Constants.incoming()

        sender_name = Map.get(senders, message.user_id)

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
        type: state.chat.type,
        avatar_url: avatar_url,
        members: state.members
      }
    }

    UserSession.send_chat_info(us_pid, chat_info)

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end

  @impl true
  def handle_cast({:send_message, msg_front, _sender_us_pid}, state) do
    front_msg_id = msg_front["front_msg_id"]
    chat_id = msg_front["chat_id"]
    content = msg_front["content"]
    sender_user_id = msg_front["sender_user_id"]
    format = msg_front["format"]
    filename = msg_front["filename"]

    msg_state =
      if state.chat.type == "private" do
        other_user_id =
          state.members
          |> Enum.map(& &1.user_id)
          |> Enum.find(&(&1 != sender_user_id))

        case ProcessRegistry.whereis_user_session(other_user_id) do
          nil ->
            Constants.state_sent()

          pid ->
            if UserSession.socket_alive?(pid) do
              Constants.state_delivered()
            else
              Constants.state_sent()
            end
        end
      else
        Constants.state_sent()
      end

    attrs = %{
      chat_id: chat_id,
      content: content,
      user_id: sender_user_id,
      state: msg_state,
      format: format,
      filename: filename
    }

    case Messages.create_message(attrs) do
      {:ok, message} ->
        base_message =
          message
          |> Map.from_struct()
          |> Map.drop([:__meta__, :user, :chat])
          |> Map.put(:time, message.inserted_at)
          |> Map.put(:avatar_url, User.get_avatar_url(sender_user_id))
          |> Map.delete(:inserted_at)

        IO.inspect(base_message, label: "Base message para incoming")

        {alive_sessions, _dead_users} =
          Enum.reduce(state.members, {[], []}, fn member, {alive, dead} ->
            user_id = member.user_id

            case ProcessRegistry.whereis_user_session(user_id) do
              nil ->
                {alive, [user_id | dead]}

              us_pid ->
                {[{user_id, us_pid} | alive], dead}
            end
          end)

        Enum.each(alive_sessions, fn {sess_user_id, us_pid} ->
          username = Repo.get(Echo.Schemas.User, sess_user_id).username

          IO.puts(
            "=|=|=|=|=|=|=|=|=|=|=|=|  Usuario VIVO: #{username} |=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|"
          )

          case sess_user_id == sender_user_id do
            # Es ougoing
            true ->
              sender_name = User.get_usable_name(sender_user_id, sender_user_id, nil)

              UserSession.new_message(
                us_pid,
                %{
                  type: "new_message",
                  message:
                    base_message
                    |> Map.put(:front_msg_id, front_msg_id)
                    |> Map.put(:type, Constants.outgoing())
                    |> Map.put(:sender_name, sender_name)
                }
              )

            # Es incoming
            false ->
              sender_name = User.get_usable_name(sess_user_id, sender_user_id, nil)

              UserSession.new_message(
                us_pid,
                %{
                  type: "new_message",
                  message:
                    base_message
                    |> Map.put(:front_msg_id, nil)
                    |> Map.put(:type, Constants.incoming())
                    |> Map.put(:sender_name, sender_name)
                }
              )
          end
        end)

        # Enum.each(dead_users, fn us_pid ->
        #   nil
        #   # Agregar una notificacion o como lo hagamos
        # end)

        {:noreply,
         %{
           state
           | last_activity: DateTime.utc_now(),
             last_messages: [base_message | state.last_messages]
         }}

      {:error, _changeset} ->
        # UserSession.send_message_error(sender_us_pid, front_msg_id, changeset)
        {:noreply, %{state | last_activity: DateTime.utc_now()}}
    end
  end

  @impl true
  def handle_cast({:chat_messages_read, chat_id, reader_user_id}, state) do
    Chat.set_messages_read(chat_id, reader_user_id)

    new_last_messages =
      Enum.map(state.last_messages, fn msg ->
        if msg.user_id != reader_user_id and msg.state != Constants.state_read() do
          %{msg | state: Constants.state_read()}
        else
          msg
        end
      end)

    state.members
    |> Enum.map(& &1.user_id)
    |> Enum.reject(&(&1 == reader_user_id))
    |> Enum.each(fn user_id ->
      if us_pid = ProcessRegistry.whereis_user_session(user_id) do
        UserSession.chat_read(us_pid, chat_id, reader_user_id)
      end
    end)

    {:noreply, %{state | last_messages: new_last_messages, last_activity: DateTime.utc_now()}}
  end

  defp get_senders(user_id, state) do
    is_private? = state.chat.type == Constants.private_chat()

    senders_ids =
      state.last_messages
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()

    case is_private? do
      true -> %{}
      false -> User.get_usable_names(user_id, senders_ids)
    end
  end
end
