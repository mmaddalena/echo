defmodule Echo.Schemas.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifications" do
    field :is_read, :boolean, default: false
    field :read_at, :utc_datetime

    # Timestamps para tracking de updates
    timestamps(type: :utc_datetime)

    # Relaciones
    belongs_to :user, Echo.Schemas.User
    belongs_to :message, Echo.Schemas.Message
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :message_id, :is_read, :read_at])
    |> validate_required([:user_id, :message_id])
    |> unique_constraint([:user_id, :message_id], name: :notifications_user_message_unique)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:message_id)
  end

  def create_changeset(user_id, message_id) do
    %__MODULE__{}
    |> changeset(%{
      user_id: user_id,
      message_id: message_id,
      is_read: false
    })
  end

  def mark_as_read_changeset(notification) do
    changeset(notification, %{
      is_read: true,
      read_at: DateTime.utc_now()
    })
  end
end
