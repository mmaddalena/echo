defmodule Echo.Users.UserSessionSup do
  # Es el supervisor de los UserSession. Es un dynamic supervisor,
  # para que cuando cada usuario inicie sesión, se cree su respectivo UserSession que
  # se quede pendiente a las requests provenientes de ese usuario.


    def start_link(_arg) do
      DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end


  def get_or_start(user_id) do
    with {:ok, user_session} <- Echo.Users.UserRegistry.lookup(user_id) do
      {:ok, user_session}
    else
      _ ->
        {:ok, pid} = start_session(user_id)
        Echo.Users.UserRegistry.put(user_id, pid)
        {:ok, pid}
    end
  end

  defp start_session(user_id) do
    spec = {Echo.Users.UserSession, %{user_id: user_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end


  @impl true
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

end
