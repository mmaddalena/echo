defmodule Echo.Users.User do
  # Llama a la DB para querys correspondientes a Usuarios

  # Funciones que (probablemente) usen Ecto...

  import Ecto.Query
  alias Echo.Repo
  alias Echo.ProcessRegistry
  alias Echo.Schemas.User
  alias Echo.Schemas.Chat
  alias Echo.Schemas.ChatMember
  alias Echo.Schemas.Contact


  def get(id) do
    Repo.get(User, id)
  end

  def get_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def update_username(user_id, new_username) do
    user = Repo.get(User, user_id)

    case user do
      nil ->
        {:error, :not_found}

      user ->
        user
        |> User.changeset(%{username: new_username})
        |> Repo.update()
        # Devuelve {:ok, %User{}} o {:error, %Ecto.Changeset{}}
    end
  end


  def change_password(user_id, new_pw) do
    user = Repo.get(User, user_id)

    case user do
      nil ->
        {:error, :not_found}

      user ->
        user
        |> User.registration_changeset(%{password: new_pw})
        |> Repo.update()
        # Devuelve {:ok, %User{}} o {:error, %Ecto.Changeset{}}
    end
  end

  def create(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # Devuelve un array de maps de chats que contienen:
  # {
  #    "id": "chat_3",
  #    "name": "Manu",
  #    "type": "grupal|MD",
  #    "avatar_url: "https://cdn.echo.app/avatars/user_8f3a21c9.png"
  #    "unread_messages": 8
  #    "last_message": {
  #      "type": "incoming",
  #      "content": "Ahí voy",
  #      "state": "delivered",
  #      "time": "2026-01-09T12:10:00Z"
  #    },
  #  }
  def last_chats(user_id) do
    query =
      from(chat in Chat,
        join: cm in ChatMember,
        on: cm.chat_id == chat.id,
        where: cm.user_id == ^user_id,

        # otro miembro del chat
        join: other_cm in ChatMember,
        on: other_cm.chat_id == chat.id and other_cm.user_id != ^user_id,

        join: other_user in User,
        on: other_user.id == other_cm.user_id,

        # contacto (puede no existir)
        left_join: contact in Contact,
        on: contact.user_id == ^user_id and contact.contact_id == other_user.id,

        order_by: [desc: chat.updated_at],

        select: %{
          id: chat.id,
          type: chat.type,
          other_user_id: other_user.id,

          name:
            fragment(
              """
              CASE
                WHEN ? = 'private'
                THEN COALESCE(?, ?, ?)
                ELSE ?
              END
              """,
              chat.type,
              contact.nickname,
              other_user.name,
              other_user.username,
              chat.name
            ),

          avatar_url:
            fragment(
              """
              CASE
                WHEN ? = 'private'
                THEN ?
                ELSE ?
              END
              """,
              chat.type,
              other_user.avatar_url,
              chat.avatar_url
            )
        }
      )

    Repo.all(query)
    |> Enum.map(fn chat ->
      status =
        if chat.type == "private" do
          if is_active?(chat.other_user_id), do: "Online", else: "Offline"
        else
          nil
        end

      chat
      |> Map.put(:status, status)
      |> Map.delete(:other_user_id)
      |> Map.put(:unread_messages, get_unread_messages(user_id, chat.id))
      |> Map.put(:last_message, get_last_message(user_id, chat.id))
    end)
  end

  def user_payload(user) do
    %{
      id: user.id,
      username: user.username,
      name: user.name,
      email: user.email,
      avatar_url: user.avatar_url,
      last_seen_at: user.last_seen_at
    }
  end


  defp is_active?(user_id) do
    case ProcessRegistry.whereis_user_session(user_id) do
      nil -> false
      _ -> true
    end
  end

  defp get_unread_messages(user_id, chat_id) do
    # Find the chat member to get last_read_at
    chat_member = Repo.get_by(ChatMember, chat_id: chat_id, user_id: user_id)
    
    if is_nil(chat_member) do
      0
    else
      # Count messages that are:
      # 1. In the specified chat
      # 2. Not deleted
      # 3. Not sent by the user themselves
      # 4. Created after the user joined the chat
      # 5. Created after last_read_at (or all messages if last_read_at is nil)
      
      query = from m in Message,
        where: m.chat_id == ^chat_id,
        where: is_nil(m.deleted_at),
        where: m.user_id != ^user_id,
        where: m.inserted_at > ^chat_member.inserted_at
      
      # Add condition for last_read_at if it exists
      query = if chat_member.last_read_at do
        from m in query,
          where: m.inserted_at > ^chat_member.last_read_at
      else
        query
      end
      
      Repo.aggregate(query, :count, :id)
    end
  end

  defp get_last_message(user_id, chat_id) do
    chat_member = Repo.get_by(ChatMember, chat_id: chat_id, user_id: user_id)
      
      if is_nil(chat_member) do
        nil
      else
        query = from m in Message,
          where: m.chat_id == ^chat_id,
          where: is_nil(m.deleted_at),
          order_by: [desc: m.inserted_at, desc: m.id],
          limit: 1,
          select: %{
            id: m.id,
            content: m.content,
            type: fragment("CASE WHEN ? = ? THEN 'outgoing' ELSE 'incoming' END", m.user_id, ^user_id),
            state: m.state,
            time: m.inserted_at
          },
          preload: [:user]  # Preload user details if needed
        Repo.one(query)
      end
  end

end
