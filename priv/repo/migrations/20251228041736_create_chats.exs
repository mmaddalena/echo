defmodule Echo.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string, null: false, default: "private"
      add :created_by_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      # Timestamps por si se edita el nombre
      add :created_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    # Índices
    create index(:chats, [:type])
    create index(:chats, [:created_by_id])
    create index(:chats, [:created_at])
  end
end
