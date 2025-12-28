defmodule Echo.Repo.Migrations.CreateUserStatuses do
  use Ecto.Migration

  def change do
    create table(:user_statuses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "inactive"
      add :last_seen_at, :utc_datetime

      # Timestamps para tracking
      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    # Índices
    create unique_index(:user_statuses, [:user_id], name: :user_statuses_user_id_index)
    create index(:user_statuses, [:status])
    create index(:user_statuses, [:last_seen_at])
  end
end
