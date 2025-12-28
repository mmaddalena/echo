defmodule Echo.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create table(:chat_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :joined_at, :utc_datetime, null: false
      add :last_read_at, :utc_datetime

      # Timestamps para tracking de last_read_at updates
      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    # Índices
    create unique_index(:chat_members, [:chat_id, :user_id],
           name: :chat_members_chat_user_unique)

    create index(:chat_members, [:chat_id])
    create index(:chat_members, [:user_id])
    create index(:chat_members, [:last_read_at])
  end
end
