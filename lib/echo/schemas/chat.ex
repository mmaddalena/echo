defmodule Echo.Schemas.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chats" do
    field :name, :string
    field :avatar_url, :string
    field :type, :string, default: "private"
    timestamps(type: :utc_datetime)

    belongs_to :creator, Echo.Schemas.User
    has_many :chat_members, Echo.Schemas.ChatMember
    has_many :messages, Echo.Schemas.Message
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :type, :creator_id])
    |> validate_required([:type, :creator_id])
    |> validate_inclusion(:type, ["private", "group"])
    |> validate_name_based_on_type()
    |> foreign_key_constraint(:creator_id)
  end

  defp validate_name_based_on_type(changeset) do
    type = get_field(changeset, :type)
    name = get_field(changeset, :name)

    case type do
      "private" ->
        # Private chats should not have names
        if is_nil(name) do
          changeset
        else
          add_error(changeset, :name, "Private chats cannot have names")
        end

      "group" ->
        # Group chats must have names
        if is_nil(name) or String.trim(name) == "" do
          add_error(changeset, :name, "Group chats require a name")
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  def private_chat_changeset(creator_id) do
    %__MODULE__{}
    |> changeset(%{
      type: "private",
      creator_id: creator_id,
      name: nil
    })
  end

  def group_chat_changeset(creator_id, name) do
    %__MODULE__{}
    |> changeset(%{
      type: "group",
      creator_id: creator_id,
      name: name
    })
  end
end
