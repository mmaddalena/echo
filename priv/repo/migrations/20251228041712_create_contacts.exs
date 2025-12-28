defmodule Echo.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :contact_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :added_at, :utc_datetime, null: false
    end

    # Índices y constraints
    create unique_index(:contacts, [:user_id, :contact_id],
           name: :contacts_user_contact_unique)

    create index(:contacts, [:user_id])
    create index(:contacts, [:contact_id])

    # Constraint para evitar auto-contacto
    execute """
      ALTER TABLE contacts
      ADD CONSTRAINT contact_cannot_be_self
      CHECK (user_id != contact_id)
    """
  end
end
