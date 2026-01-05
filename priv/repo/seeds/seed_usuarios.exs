alias Echo.Repo
alias Echo.Schemas.User

users = [
  %{
    "username" => "lucas",
    "password" => "12345678",
    "email" => "lucas@coutt.com",
    "name" => "Lucas Couttulenc"
  },
  %{
    "username" => "martin",
    "password" => "12345678",
    "email" => "martin@maddalena.com"
  }
]

Enum.each(users, fn attrs ->
  %User{}
  |> User.registration_changeset(attrs)
  |> Repo.insert!(
    on_conflict: :nothing,
    conflict_target: :username
  )
end)

IO.puts("✅ Usuarios creados correctamente")
