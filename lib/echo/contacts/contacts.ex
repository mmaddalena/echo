defmodule Echo.Contacts.Contacts do
  import Ecto.Query
  alias Echo.Schemas.Contact

  def list_contacts_for_user(user_id) do
    from(c in Contact,
      where: c.user_id == ^user_id,
      preload: [:contact]
    )
    |> Echo.Repo.all()
  end

  def get_contact_between(owner_user_id, contact_user_id) do
    from(c in Contact,
      where:
        c.user_id == ^owner_user_id and
        c.contact_id == ^contact_user_id,
      preload: [:contact]
    )
    |> Echo.Repo.one()
  end
end
