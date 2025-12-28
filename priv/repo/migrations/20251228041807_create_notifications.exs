defmodule Echo.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :message_id, references(:messages, type: :binary_id, on_delete: :delete_all), null: false
      add :is_read, :boolean, null: false, default: false
      add :read_at, :utc_datetime

      # Timestamps para tracking
      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    # Índices
    create unique_index(:notifications, [:user_id, :message_id],
           name: :notifications_user_message_unique)

    create index(:notifications, [:user_id, :is_read])
    create index(:notifications, [:message_id])
    create index(:notifications, [:is_read])
    create index(:notifications, [:created_at])
  end
end
