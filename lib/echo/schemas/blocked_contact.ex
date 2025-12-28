defmodule Echo.Schemas.BlockedContact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "blocked_contacts" do
    field :blocked_at, :utc_datetime

    # Relaciones
    belongs_to :user, Echo.Schemas.User
    belongs_to :blocked_user, Echo.Schemas.User, foreign_key: :blocked_user_id

    # No timestamps
  end

  def changeset(blocked_contact, attrs) do
    blocked_contact
    |> cast(attrs, [:user_id, :blocked_user_id, :blocked_at])
    |> validate_required([:user_id, :blocked_user_id])
    |> put_change(:blocked_at, attrs[:blocked_at] || DateTime.utc_now())
    |> unique_constraint([:user_id, :blocked_user_id],
      name: :blocked_contacts_user_blocked_unique
    )
    |> check_constraint(:user_id, name: :cannot_block_self, message: "Cannot block yourself")
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:blocked_user_id)
  end
end
