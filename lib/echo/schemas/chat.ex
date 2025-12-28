defmodule Echo.Schemas.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chats" do
    field :name, :string
    # "private" | "group"
    field :type, :string, default: "private"

    # Timestamps para posible edición de nombre
    timestamps(type: :utc_datetime)

    # Relaciones
    belongs_to :created_by, Echo.Schemas.User
    has_many :chat_members, Echo.Schemas.ChatMember
    has_many :messages, Echo.Schemas.Message
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :type, :created_by_id])
    |> validate_required([:type, :created_by_id])
    |> validate_inclusion(:type, ["private", "group"])
    |> foreign_key_constraint(:created_by_id)
  end

  def private_chat_changeset(user1_id) do
    %__MODULE__{}
    |> changeset(%{
      type: "private",
      created_by_id: user1_id,
      # Los chats privados no tienen nombre
      name: nil
    })
  end

  def group_chat_changeset(creator_id, name) do
    %__MODULE__{}
    |> changeset(%{
      type: "group",
      name: name,
      created_by_id: creator_id
    })
  end
end
