defmodule Echo.Users.User do
  # Llama a la DB para querys correspondientes a Usuarios

  # Funciones que (probablemente) usen Ecto...

  alias Echo.Repo
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

  def last_chats(user_id) do
    from chat in Chat,
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
      on:
        contact.user_id == ^user_id and
        contact.contact_id == other_user.id,

      order_by: [desc: chat.updated_at],

      select: %{
        chat_id: chat.id,
        chat_type: chat.type,

        chat_name:
          fragment(
            """
            CASE
              WHEN ? = 'privado'
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
            WHEN ? = 'privado'
            THEN ?
            ELSE ?
          END
          """,
          chat.type,
          other_user.avatar_url,
          chat.avatar_url
        )
      }
  end

end
