defmodule Echo.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :content, :text, null: false
      add :deleted_at, :utc_datetime
      add :created_at, :utc_datetime, null: false  # Solo created_at, sin updated_at
    end

    # Índices
    create index(:messages, [:chat_id, :created_at])  # Para últimos mensajes
    create index(:messages, [:user_id])
    create index(:messages, [:deleted_at])
    create index(:messages, [:created_at])

    # Índice para búsqueda (si usas LIKE)
    execute "CREATE INDEX messages_content_search_idx ON messages USING gin(to_tsvector('spanish', content))"
  end
end
