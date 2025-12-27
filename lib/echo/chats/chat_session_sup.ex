defmodule Echo.Chats.ChatSessionSup do
  use DynamicSupervisor
  # Idem que el ChatSessionSup.
  # Es un supervisor dinámico que maneja los ChatSession.

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end


  def get_or_start(chat_id) do
    with {:ok, chat_session} <- Echo.Chats.ChatRegistry.lookup(chat_id) do
      {:ok, chat_session}
    else
      _ ->
        {:ok, pid} = start_chat(chat_id)
        Echo.Chats.ChatRegistry.put(chat_id, pid)
        {:ok, pid}
    end
  end

  defp start_chat(chat_id) do
    spec = {Echo.Chats.ChatSession, %{chat_id: chat_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end


  @impl true
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end
end
