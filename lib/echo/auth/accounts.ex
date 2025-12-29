defmodule Echo.Auth.Accounts do
  @moduledoc """
  Módulo para manejar operaciones de cuenta de usuario.
  """

  alias Echo.Auth.Auth
  alias Echo.Users.UserSessionSup

  @doc """
  Inicia sesión de un usuario.

  Returns:
    - {:ok, token} si el login es exitoso
    - {:error, reason} si hay un error
  """
  def login(username, password) do
    with {:ok, user_id} <- Auth.authenticate(username, password),
         {:ok, _user_session} <- UserSessionSup.get_or_start(user_id),
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
    - {:ok, user} si el registro es exitoso
    - {:error, changeset} si hay errores de validación
    - {:error, :username_taken} si el username ya existe
  """
  def register(username, password) do
    # Hashear la contraseña
    password_hash = Auth.hash_password(password)

    # Crear usuario (aquí iría la lógica de base de datos)
    case User.create(%{
           username: username,
           password_hash: password_hash
         }) do
      {:ok, user} ->
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
