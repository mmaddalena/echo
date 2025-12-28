defmodule Echo.Schemas.ChatMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chat_members" do
    field :joined_at, :utc_datetime
    field :last_read_at, :utc_datetime

    # Timestamps para tracking de last_read_at updates
    timestamps(type: :utc_datetime)

    # Relaciones
    belongs_to :chat, Echo.Schemas.Chat
    belongs_to :user, Echo.Schemas.User
  end

  def changeset(chat_member, attrs) do
    chat_member
    |> cast(attrs, [:chat_id, :user_id, :joined_at, :last_read_at])
    |> validate_required([:chat_id, :user_id])
    |> put_change(:joined_at, attrs[:joined_at] || DateTime.utc_now())
    |> unique_constraint([:chat_id, :user_id], name: :chat_members_chat_user_unique)
    |> foreign_key_constraint(:chat_id)
    |> foreign_key_constraint(:user_id)
  end

  def mark_as_read_changeset(chat_member) do
    changeset(chat_member, %{
      last_read_at: DateTime.utc_now()
    })
  end
end
