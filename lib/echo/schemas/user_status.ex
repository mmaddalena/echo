defmodule Echo.Schemas.UserStatus do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_statuses" do
    # "active" | "inactive"
    field :status, :string, default: "inactive"
    field :last_seen_at, :utc_datetime

    # Timestamps para tracking de actualizaciones
    timestamps(type: :utc_datetime)

    # Relaciones
    belongs_to :user, Echo.Schemas.User
  end

  def changeset(user_status, attrs) do
    user_status
    |> cast(attrs, [:status, :last_seen_at, :user_id])
    |> validate_required([:status, :user_id])
    |> validate_inclusion(:status, ["active", "inactive"])
    |> unique_constraint(:user_id, name: :user_statuses_user_id_index)
    |> foreign_key_constraint(:user_id)
  end

  def update_status_changeset(user_status, status) do
    changeset(user_status, %{
      status: status,
      last_seen_at: DateTime.utc_now()
    })
  end
end
