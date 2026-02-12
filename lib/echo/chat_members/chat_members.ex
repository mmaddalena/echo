defmodule Echo.ChatMembers.ChatMembers do
  import Ecto.Query
  alias Echo.Repo
  alias Echo.Schemas.ChatMember

  def set_last_read(user_id, chat_id) do
    from(cm in ChatMember,
      where: cm.user_id == ^user_id and cm.chat_id == ^chat_id
    )
    |> Repo.update_all(set: [last_read_at: DateTime.utc_now()])
  end

  def member?(chat_id, user_id) do
    Repo.exists?(
      from cm in Echo.Schemas.ChatMember,
        where: cm.chat_id == ^chat_id and cm.user_id == ^user_id
    )
  end

  @doc """
  Returns all members of a chat as a list of ChatMember structs,
  ordered by `inserted_at` ascending (oldest first).
  """
  def get_all_members(chat_id) do
    from(cm in ChatMember,
      where: cm.chat_id == ^chat_id,
      order_by: [asc: cm.inserted_at]
    )
    |> Repo.all()
  end
end
