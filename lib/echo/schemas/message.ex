defmodule Echo.Schemas.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    field :content, :string
    field :deleted_at, :utc_datetime
    # Solo created_at, sin updated_at
    field :created_at, :utc_datetime

    # Relaciones
    belongs_to :chat, Echo.Schemas.Chat
    belongs_to :user, Echo.Schemas.User
    has_many :notifications, Echo.Schemas.Notification
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :chat_id, :user_id, :deleted_at, :created_at])
    |> validate_required([:content, :chat_id, :user_id])
    |> put_change(:created_at, attrs[:created_at] || DateTime.utc_now())
    |> foreign_key_constraint(:chat_id)
    |> foreign_key_constraint(:user_id)
    |> validate_length(:content, min: 1, max: 5000)
  end

  def create_changeset(chat_id, user_id, content) do
    %__MODULE__{}
    |> changeset(%{
      chat_id: chat_id,
      user_id: user_id,
      content: content,
      created_at: DateTime.utc_now()
    })
  end

  def soft_delete_changeset(message) do
    change(message, %{
      deleted_at: DateTime.utc_now()
    })
  end
end
