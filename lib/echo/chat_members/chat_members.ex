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
end
