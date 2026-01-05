defmodule Echo.Auth.Accounts do
  @moduledoc """
  Módulo para manejar operaciones de cuenta de usuario.
  """

  alias Echo.Auth.Auth
  alias Echo.Users.UserSessionSup
  alias Echo.Users.User

  @doc """
  Inicia sesión de un usuario.

  Returns:
    - {:ok, token} si el login es exitoso
    - {:error, reason} si hay un error
  """
  def login(username, password) do
    with {:ok, user_id} <- Auth.authenticate(username, password),
         {:ok, token} <- Auth.create_token(user_id) do
      {:ok, token}
    else
      {:error, reason} ->
        IO.puts(reason)
        {:error, reason}
    end
  end

  @doc """
  Registra un nuevo usuario.

  Returns:
    - {:ok, token} si el registro (y post login) es exitoso
    - {:error, changeset} si hay errores de validación
    - {:error, :username_taken} si el username ya existe
  """
  def register(username, password, name, email) do
    case User.create(%{
           username: username,
           password: password,
           name: name,
           email: email
         }) do
      {:ok, _user} ->
        # Iniciar sesión automáticamente después del registro
        login(username, password)

      {:error, :username_taken} ->
        {:error, :username_taken}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Cierra sesión de un usuario.
  """
  def logout(token) do
    # Con JWT stateless, el logout se maneja en el cliente
    # eliminando el token. Pero podríamos invalidar el token
    # si implementamos una blacklist.
    :ok
  end
end
