defmodule Echo.Auth.Accounts do
  # Este es un modulo que orquesta, se llama desde Router.
  # Basicamente orquesta lo relacionado con usuarios (login, logout, cambiar contraseña, etc)
  # No relacionado a mensajes, ya que eso lo hace Echo.Messages.Messages (se podria cambiar el nombre)
  # Lo puse aca en Auth porque me pareció lógico por el momento, probablemente lo movamos a otro lado si es mejor.


  def login(username, password) do
    with {:ok, user_id} <- Echo.Auth.Auth.authenticate(username, password),
         {:ok, token} <- Echo.Auth.Auth.create_token(user_id),
         {:ok, _user_id} <- Echo.Users.UserSessionSup.get_or_start(user_id),
         {:ok, _} <- Echo.Auth.TokenStore.put(token, user_id)
    do
      {:ok, token}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
