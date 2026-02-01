defmodule Echo.Contacts.Contacts do
  import Ecto.Query

  def list_contacts_for_user(user_id) do
    from(c in Echo.Schemas.Contact,
      where: c.user_id == ^user_id,
      preload: [:contact]
    )
    |> Echo.Repo.all()
  end

end
