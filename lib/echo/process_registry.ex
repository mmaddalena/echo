defmodule Echo.ProcessRegistry do
  @moduledoc """
  Registry global para procesos de dominio:
  - {:user, user_id} -> UserSession pid
  - {:chat, chat_id} -> ChatSession pid
  """

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end
end
