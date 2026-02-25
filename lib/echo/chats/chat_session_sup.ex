defmodule Echo.Chats.ChatSessionSup do
  use DynamicSupervisor
  # Idem que el ChatSessionSup.
  # Es un supervisor dinámico que maneja los ChatSession.

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_or_start(chat_id) do
    case Registry.lookup(Echo.ProcessRegistry, {:chat, chat_id}) do
      [{pid, _value}] ->
        {:ok, pid}

      [] ->
        case start_session(chat_id) do
          {:ok, pid} -> {:ok, pid}
          # Creo que solo llegaría acá en una Race Condition
          {:error, {:already_started, pid}} -> {:ok, pid}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp start_session(chat_id) do
    spec = %{
      id: {Echo.Chats.ChatSession, chat_id},
      start: {Echo.Chats.ChatSession, :start_link, [chat_id]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
