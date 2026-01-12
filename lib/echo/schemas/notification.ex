defmodule Echo.Schemas.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notifications" do
    field :read_at, :utc_datetime
    timestamps(type: :utc_datetime)

    belongs_to :user, Echo.Accounts.User
    belongs_to :chat, Echo.Chats.Chat
    belongs_to :message, Echo.Messages.Message
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :chat_id, :message_id, :read_at])
    |> validate_required([:user_id, :chat_id, :message_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:chat_id)
    |> foreign_key_constraint(:message_id)
    |> unique_constraint([:user_id, :message_id], name: :notifications_user_id_message_id_index)
  end

  def mark_read_changeset(notification) do
    notification
    |> change(read_at: DateTime.utc_now())
  end
end
