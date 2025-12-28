defmodule Echo.Repo.Migrations.CreateBlockedContacts do
  use Ecto.Migration

  def change do
    create table(:blocked_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :blocked_user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :blocked_at, :utc_datetime, null: false
    end

    # Índices y constraints
    create unique_index(:blocked_contacts, [:user_id, :blocked_user_id],
           name: :blocked_contacts_user_blocked_unique)

    create index(:blocked_contacts, [:user_id])
    create index(:blocked_contacts, [:blocked_user_id])

    # Constraint para evitar auto-bloqueo
    execute """
      ALTER TABLE blocked_contacts
      ADD CONSTRAINT cannot_block_self
      CHECK (user_id != blocked_user_id)
    """
  end
end
