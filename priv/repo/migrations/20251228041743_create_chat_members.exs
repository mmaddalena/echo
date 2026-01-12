defmodule Echo.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create table(:chat_members, primary_key: false) do
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all), primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), primary_key: true
      timestamps(type: :utc_datetime)
    end

    create index(:chat_members, [:chat_id])
    create index(:chat_members, [:user_id])
  end
end
