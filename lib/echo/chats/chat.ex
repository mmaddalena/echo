defmodule Echo.Chats.Chat do
  # Define la estructura del usuario con el schema
  # Llama a la DB para querys correspondientes a Usuarios

  # Funciones que (probablemente) usen Ecto...

  import Ecto.Query
  alias Echo.Repo
  alias Echo.ProcessRegistry
  alias Echo.Schemas.User
  alias Echo.Schemas.Chat
  alias Echo.Schemas.ChatMember
  alias Echo.Schemas.Message
  alias Echo.Constants

  def get(chat_id) do
    Repo.get(Chat, chat_id)
  end

  def get_by_algo(username) do
  end

  def update_smth(smth) do
  end

  def get_last_messages(chat_id) do
    from(m in Message,
      join: u in User,
      on: u.id == m.user_id,
      where: m.chat_id == ^chat_id,
      where: is_nil(m.deleted_at),
      order_by: [desc: m.inserted_at, desc: m.id],
      limit: ^Constants.messages_page_size(),
      select: %{
        id: m.id,
        content: m.content,
        user_id: m.user_id,
        chat_id: m.chat_id,
        state: m.state,
        time: m.inserted_at,
        deleted_at: m.deleted_at,
        avatar_url: u.avatar_url
      }
    )
    |> Repo.all()
    |> Enum.reverse()
  end

  def get_members(chat_id) do
    from(cm in ChatMember,
      join: u in User,
      on: u.id == cm.user_id,
      where: cm.chat_id == ^chat_id,
      select: %{
        user_id: u.id,
        username: u.username,
        name: u.name,
        avatar_url: u.avatar_url,
        last_read_at: cm.last_read_at
      }
    )
    |> Repo.all()
  end

  def get_other_user_id(chat_id, user_id) do
    from(cm in ChatMember,
      join: c in Chat,
      on: c.id == cm.chat_id,
      where:
        cm.chat_id == ^chat_id and
          cm.user_id != ^user_id and
          c.type == "private",
      select: cm.user_id,
      limit: 1
    )
    |> Repo.one()
  end

  def get_avatar_url(chat, other_user_id) do
    case chat.type do
      "private" ->
        Repo.get!(User, other_user_id).avatar_url

      _group ->
        chat.avatar_url
    end
  end

  def set_messages_read(chat_id, reader_user_id) do
    if Repo.get(Chat, chat_id).type == Constants.private_chat() do
      from(m in Message,
        where:
          m.chat_id == ^chat_id and
            m.user_id != ^reader_user_id and
            m.state != ^Constants.state_read()
      )
      |> Repo.update_all(set: [state: Constants.state_read()])
    end

    # Si implementamos el state en grupales ponemos un else aca y lo hacemos
  end
end
