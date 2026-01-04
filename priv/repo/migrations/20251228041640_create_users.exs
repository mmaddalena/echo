defmodule Echo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
          add :id, :binary_id, primary_key: true
          add :username, :string, null: false
          add :password_hash, :string, null: false
          add :name, :string
          add :email, :string, null: false

          # Timestamps sin inserted_at
          add :created_at, :utc_datetime, null: false
          add :updated_at, :utc_datetime, null: false
      end

    create unique_index(:users, [:username], name: :users_username_index)
    create index(:users, [:created_at])
  end
end
