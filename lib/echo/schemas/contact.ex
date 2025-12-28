defmodule Echo.Schemas.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "contacts" do
    field :added_at, :utc_datetime

    # Relaciones
    belongs_to :user, Echo.Schemas.User
    belongs_to :contact, Echo.Schemas.User, foreign_key: :contact_id

    # Índice compuesto para evitar duplicados
    # timestamps no necesarios aquí
  end

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:user_id, :contact_id, :added_at])
    |> validate_required([:user_id, :contact_id])
    |> put_change(:added_at, attrs[:added_at] || DateTime.utc_now())
    |> unique_constraint([:user_id, :contact_id], name: :contacts_user_contact_unique)
    |> check_constraint(:user_id,
      name: :contact_cannot_be_self,
      message: "Cannot add yourself as contact"
    )
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:contact_id)
  end

  def add_contact_changeset(user_id, contact_id) do
    %__MODULE__{}
    |> changeset(%{
      user_id: user_id,
      contact_id: contact_id,
      added_at: DateTime.utc_now()
    })
  end
end
