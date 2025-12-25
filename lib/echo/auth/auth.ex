defmodule Echo.Auth.Auth do
  # Es el authenticator de la app, valida todo lo necesario.

  def authenticate(username, pw) do
    # {:ok, user_id}
    # {:error, reason (no hay usuario || pw incorrecta)}
  end

  def create_token(user_id) do
    # token (numero aleatorio)
  end

  def verify_token(token) do
    # Busca en el tokenstore si esta.
    # {:ok, user_id}
    # {:error, :invalid_token}
  end

end
