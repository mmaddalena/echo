alias Echo.Repo
alias Echo.Schemas.User

users = [
  %{
    "username" => "lucas",
    "password" => "123456"
  },
  %{
    "username" => "martin",
    "password" => "123456"
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
