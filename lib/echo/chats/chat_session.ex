defmodule Echo.Chats.ChatSession do
  alias Echo.ProcessRegistry
  alias Echo.Users.UserSessionSup
  alias Echo.Chats.ChatSessionSup
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
        type: state.chat.type,
        avatar_url: avatar_url,
        members: state.members
      }
    }

    UserSession.send_chat_info(us_pid, chat_info)

    {:noreply, %{state | last_activity: DateTime.utc_now()}}
  end


  @impl true
  def handle_cast({:send_message, msg_front, sender_us_pid}, state) do
    front_msg_id = msg_front["front_msg_id"]
    chat_id = msg_front["chat_id"]
    content = msg_front["content"]
    sender_user_id = msg_front["sender_user_id"]

    attrs = %{
      chat_id: chat_id,
      content: content,
      user_id: sender_user_id
    }

    case Messages.create_message(attrs) do
      {:ok, message} ->
        base_message =
          message
          |> Map.from_struct()
          |> Map.drop([:__meta__, :user, :chat])
          |> Map.put(:state, Constants.state_sent())
          |> Map.put(:time, message.inserted_at)
          |> Map.delete(:inserted_at)

        {alive_sessions, dead_users} =
          Enum.reduce(state.members, {[], []}, fn member, {alive, dead} ->
            user_id = member.id
            case ProcessRegistry.whereis_user_session(user_id) do
              nil ->
                {alive, [user_id | dead]}
              us_pid ->
                {[{user_id, us_pid} | alive], dead}
            end
          end)

        Enum.each(alive_sessions, fn {user_id, us_pid} ->
          username = Repo.get(Echo.Schemas.User, user_id).username

          IO.puts("=|=|=|=|=|=|=|=|=|=|=|=|  Usuario VIVO: #{username} |=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|")
          case user_id == sender_user_id do
            true ->
              UserSession.new_message(us_pid,
                %{
                  type: "new_message",
                  message: Map.put(base_message, :front_msg_id, front_msg_id)
                }
              )
            false ->
              UserSession.new_message(us_pid,
                %{
                  type: "new_message",
                  message: Map.put(base_message, :type, Constants.incoming())
                }
              )
          end
        end)

        Enum.each(dead_users, fn us_pid ->
          # Agregar una notificacion o como lo hagamos
        end)

        {:noreply,
          %{
            state |
              last_activity: DateTime.utc_now(),
              last_messages: [base_message | state.last_messages]
          }
        }

      {:error, changeset} ->
        #UserSession.send_message_error(sender_us_pid, front_msg_id, changeset)
        {:noreply, %{state | last_activity: DateTime.utc_now()}}
    end
  end




end
