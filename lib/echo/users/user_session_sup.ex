defmodule Echo.Users.UserSessionSup do
  # Es el supervisor de los UserSession. Es un dynamic supervisor,
  # para que cuando cada usuario inicie sesión, se cree su respectivo UserSession que
  # se quede pendiente a las requests provenientes de ese usuario.


  def get_or_start(user_id) do
    with {:ok, user_session} <- Echo.Users.UserRegistry.get(user_id) do

    else
      {:error, :no_user_session} -> # Crear nuevo user session con este user_id y agregarlo al UserRegistry.
    end
  end

end
