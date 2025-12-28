defmodule Echo.Users.User do
  # Llama a la DB para querys correspondientes a Usuarios

  # Funciones que (probablemente) usen Ecto...

  alias Echo.Repo
  alias Echo.Schemas.User

  def get(id) do
    Repo.get(User, id)
  end

  def get_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def update_username(user_id, new_username) do
    user = Repo.get(User, user_id)

    case user do
      nil ->
        {:error, :not_found}

      user ->
        user
        |> User.changeset(%{username: new_username})
        |> Repo.update()
        # Devuelve {:ok, %User{}} o {:error, %Ecto.Changeset{}}
    end
  end


end
