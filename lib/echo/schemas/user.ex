defmodule Echo.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :name, :string
    field :email, :string

    # Timestamps solo con created_at/updated_at (sin inserted_at)
    # timestamps(type: :utc_datetime)
    timestamps(inserted_at: :created_at, updated_at: :updated_at, type: :utc_datetime)

    # Relaciones
    has_one :user_status, Echo.Schemas.UserStatus
    has_many :contacts, Echo.Schemas.Contact, foreign_key: :user_id
    has_many :blocked_contacts, Echo.Schemas.BlockedContact, foreign_key: :user_id
    has_many :chat_members, Echo.Schemas.ChatMember
    has_many :messages, Echo.Schemas.Message
    has_many :notifications, Echo.Schemas.Notification
  end

  # Login
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash])
    |> validate_required([:username, :password_hash])
    |> unique_constraint(:username, name: :users_username_index)
    |> validate_length(:username, min: 3, max: 50)
  end

  # Register
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:password, min: 8)
    |> unique_constraint(:username, name: :users_username_index)
    |> unique_constraint(:email, name: :users_email_index)
    |> validate_length(:username, min: 3, max: 50)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> put_password_hash()
  end


  defp put_password_hash(%Ecto.Changeset{
        valid?: true,
        changes: %{password: password}
      } = changeset) do
    hash = Echo.Auth.Auth.hash_password(password)
    put_change(changeset, :password_hash, hash)
  end

  defp put_password_hash(changeset), do: changeset
end
