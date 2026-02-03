defmodule Echo.Contacts.Contacts do
  import Ecto.Query
  alias Echo.Schemas.Contact
  alias Echo.Repo

  def list_contacts_for_user(user_id) do
    from(c in Contact,
      where: c.user_id == ^user_id,
      preload: [:contact]
    )
    |> Repo.all()
  end

  def get_contact_between(owner_user_id, contact_id) do
    from(c in Contact,
      where:
        c.user_id == ^owner_user_id and
        c.contact_id == ^contact_id,
      preload: [:contact]
    )
    |> Repo.one()
  end

  def get_contacts_map(user_id) do
    from(c in Contact,
      where: c.user_id == ^user_id,
      select: {
        c.contact_id,
        c.nickname
      }
    )
    |> Repo.all()
    |> Map.new()
  end

end
