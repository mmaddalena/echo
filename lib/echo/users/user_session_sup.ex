defmodule Echo.Users.UserSessionSup do
  # Es el supervisor de los UserSession. Es un dynamic supervisor,
  # para que cuando cada usuario inicie sesión, se cree su respectivo UserSession que
  # se quede pendiente a las requests provenientes de ese usuario.
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

    @impl true
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end


  def get_or_start(user_id) do
    case Registry.lookup(Echo.ProcessRegistry, {:user, user_id}) do
      [{pid, _value}] ->
        {:ok, pid}

      [] ->
        case start_session(user_id) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid} # Creo que solo llegaría acá en una Race Condition
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp start_session(user_id) do
    spec = {Echo.Users.UserSession, user_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end




end
