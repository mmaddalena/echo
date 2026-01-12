defmodule Echo.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all), null: false
      add :message_id, references(:messages, type: :binary_id, on_delete: :delete_all), null: false
      add :read_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id, :read_at])
    create index(:notifications, [:message_id])
    create index(:notifications, [:chat_id])

    create unique_index(:notifications, [:user_id, :message_id])
  end
end
