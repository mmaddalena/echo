# seeds.exs
alias Echo.Repo
alias Echo.Schemas.{User, Contact, Chat, ChatMember, Message, BlockedContact}

# Helper function to truncate microseconds
truncate_datetime = fn datetime ->
  DateTime.truncate(datetime, :second)
end

# Clear existing data
IO.puts("🗑️  Clearing existing data...")
Repo.delete_all(Message)
Repo.delete_all(ChatMember)
Repo.delete_all(Chat)
Repo.delete_all(BlockedContact)
Repo.delete_all(Contact)
Repo.delete_all(User)

IO.puts("✅ Tables cleared")

# Create users
IO.puts("👥 Creating users...")

users = [
  %{
    "username" => "lucas",
    "password" => "12345678",
    "email" => "lucas@coutt.com",
    "name" => "Lucas Couttulenc",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/e1e26110-e81f-4e61-8cce-ba181a34577c-3518a9fc-74c1-4e04-afde-1e33a14d6abb.jpg"
  },
  %{
    "username" => "martin",
    "password" => "12345678",
    "email" => "martin@maddalena.com",
    "name" => "Martin Maddalena",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/3842d0fa-c8e1-4a86-982d-e43392206834-d9f4a4a0-c943-451a-b05b-2f3e58df54ab.jpeg"
  },
  %{
    "username" => "rocio",
    "password" => "12345678",
    "email" => "rocio@gallo.com",
    "name" => "Rocío Gallo",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/3842d0fa-c8e1-4a86-982d-e43392206834-0924ea9b-9d73-42b8-a117-4397d91d8167.png"
  },
  %{
    "username" => "manuel",
    "password" => "12345678",
    "email" => "manuel@camejo.com",
    "name" => "Manuel Camejo",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/3842d0fa-c8e1-4a86-982d-e43392206834-05c34105-41c9-4212-987d-6313d377d8e0.jpeg"
  },
  %{
    "username" => "matias",
    "password" => "12345678",
    "email" => "matias@onorato.com",
    "name" => "Matías Onorato",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/3842d0fa-c8e1-4a86-982d-e43392206834-42effcee-d371-459b-a25f-83ef881b3c28.jpeg"
  }
]

created_users = Enum.map(users, fn attrs ->
  user = %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert!()

  user
end)

IO.puts("✅ #{length(created_users)} users created")

# Map users for easy access
[lucas, martin, rocio, manuel, matias] = created_users

# Update last_seen_at for more realistic data (truncate microseconds)
now = truncate_datetime.(DateTime.utc_now())
yesterday = truncate_datetime.(DateTime.add(now, -86400, :second))
two_hours_ago = truncate_datetime.(DateTime.add(now, -7200, :second))

Repo.get!(User, lucas.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, martin.id) |> Ecto.Changeset.change(last_seen_at: yesterday) |> Repo.update!()
Repo.get!(User, rocio.id) |> Ecto.Changeset.change(last_seen_at: two_hours_ago) |> Repo.update!()
Repo.get!(User, manuel.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, matias.id) |> Ecto.Changeset.change(last_seen_at: two_hours_ago) |> Repo.update!()

# Create contacts (friendships)
IO.puts("🤝 Creating contacts...")

contacts = [
  # Lucas's contacts
  %{user_id: lucas.id, contact_id: martin.id, nickname: "Marto"},
  %{user_id: lucas.id, contact_id: rocio.id, nickname: "Roci"},
  %{user_id: lucas.id, contact_id: manuel.id, nickname: "Manu"},
  # Martin's contacts
  %{user_id: martin.id, contact_id: lucas.id, nickname: "Luquitas"},
  %{user_id: martin.id, contact_id: rocio.id, nickname: "Roci"},
  %{user_id: martin.id, contact_id: manuel.id, nickname: nil},
  # Rocio's contacts
  %{user_id: rocio.id, contact_id: lucas.id, nickname: "Lucasss"},
  %{user_id: rocio.id, contact_id: martin.id, nickname: "Marto"},
  %{user_id: rocio.id, contact_id: manuel.id, nickname: "Manu"},
  # Manuel's contacts
  %{user_id: manuel.id, contact_id: matias.id, nickname: "Mati"},
  # Matias's contacts
  %{user_id: matias.id, contact_id: manuel.id, nickname: "Manu"}
]

Enum.each(contacts, fn contact_attrs ->
  %Contact{}
  |> Contact.changeset(contact_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(contacts)} contacts created")

# Create blocked contacts
IO.puts("🚫 Creating blocked contacts...")

blocked_contacts = [
  # Rocio blocked Manuel
  %{blocker_id: rocio.id, blocked_id: manuel.id},
]

Enum.each(blocked_contacts, fn blocked_attrs ->
  %BlockedContact{}
  |> BlockedContact.changeset(blocked_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(blocked_contacts)} blocked contacts created")

# Create chats
IO.puts("💬 Creating chats...")

# Direct chats (private)
direct_chats = [
  %{name: nil, type: "private", creator_id: lucas.id}, # Lucas ↔ Martin
  %{name: nil, type: "private", creator_id: lucas.id}, # Lucas ↔ Manu
]

# Group chats
group_chats = [
  %{name: "CS2", type: "group", creator_id: lucas.id, avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/e1e26110-e81f-4e61-8cce-ba181a34577c-47ccfd5a-80a3-4ebf-834a-6084776fc1d0.jpg"},
  %{name: "TP FINAL Taller", type: "group", creator_id: martin.id, avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/e1e26110-e81f-4e61-8cce-ba181a34577c-33e3aba1-c8bf-4991-ac25-3013bb7e3502.png"}
]

all_chats = direct_chats ++ group_chats

created_chats = Enum.map(all_chats, fn chat_attrs ->
  %Chat{}
  |> Chat.changeset(chat_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(created_chats)} chats created")

# Map chats for reference
[lucas_martin_chat, lucas_manuel_chat, cs2_chat, tp_final_taller_chat] = created_chats

# Create chat members
IO.puts("👥 Adding members to chats...")

chat_members = [
  # Direct chat: Lucas ↔ Martin
  %{chat_id: lucas_martin_chat.id, user_id: lucas.id},
  %{chat_id: lucas_martin_chat.id, user_id: martin.id},

  # Direct chat: Lucas ↔ manu
  %{chat_id: lucas_manuel_chat.id, user_id: lucas.id},
  %{chat_id: lucas_manuel_chat.id, user_id: manuel.id},

  # Group chat: TP FINAL Taller (Lucas, Martin, Rocio)
  %{chat_id: tp_final_taller_chat.id, user_id: lucas.id},
  %{chat_id: tp_final_taller_chat.id, user_id: martin.id},
  %{chat_id: tp_final_taller_chat.id, user_id: rocio.id},

  # Group chat: CS (Lucas, Martin, Manu, Mati)
  %{chat_id: cs2_chat.id, user_id: lucas.id},
  %{chat_id: cs2_chat.id, user_id: martin.id},
  %{chat_id: cs2_chat.id, user_id: manuel.id},
  %{chat_id: cs2_chat.id, user_id: matias.id}
]

Enum.each(chat_members, fn member_attrs ->
  %ChatMember{}
  |> ChatMember.changeset(member_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(chat_members)} chat members added")

# Create messages
IO.puts("📝 Creating messages...")

# Helper function to create messages with timestamps (truncate microseconds)
create_messages = fn chat_id, sender_id, message_data ->
  Enum.map(message_data, fn {content, state, hours_ago} ->
    inserted_at = truncate_datetime.(DateTime.add(DateTime.utc_now(), -hours_ago * 3600, :second))

    %Message{}
    |> Message.changeset(%{
      chat_id: chat_id,
      user_id: sender_id,
      content: content,
      state: state
    })
    |> Ecto.Changeset.change(inserted_at: inserted_at, updated_at: inserted_at)
    |> Repo.insert!()
  end)
end

# Messages in Lucas ↔ Martin chat
create_messages.(lucas_martin_chat.id, lucas.id, [
  {"Que onda Martin?", "sent", 49},
  {"Todo bien??", "sent", 48}
])

create_messages.(lucas_martin_chat.id, martin.id, [
  {"Holaaa", "sent", 47},
  {"Todo bien y vos?", "sent", 46}
])
create_messages.(lucas_martin_chat.id, lucas.id, [
  {"Bien bien, metiendole al TP", "sent", 45},
  {"Hacemos call para seguir con las features que faltan?", "sent", 44}
])
create_messages.(lucas_martin_chat.id, martin.id, [
  {"Dale, ahí me meto a Discord", "sent", 43}
])
create_messages.(lucas_martin_chat.id, lucas.id, [
  {"De una", "sent", 42}
])

# Messages in Lucas ↔ manuel chat
create_messages.(lucas_manuel_chat.id, lucas.id, [
  {"Hola profe, todo bien?", "sent", 49},
  {"Tenía una duda sobre el TP", "sent", 48}
])
create_messages.(lucas_manuel_chat.id, manuel.id, [
  {"Hola Lucas, sí decime", "sent", 47},
])
create_messages.(lucas_manuel_chat.id, lucas.id, [
  {"Nosotros estamos haciendo un front para la app, pero el tema es que en la consigna dice que tiene que haber un cliente consola.", "sent", 46},
  {"Ya que hacemos el front como cliente, hace falta también hacer el cliente consola? O eso es solo para los que no hacen front?", "sent", 44}
])
create_messages.(lucas_manuel_chat.id, manuel.id, [
  {"No no hace falta que hagan dos clientes, manden el front y listo", "sent", 43}
])
create_messages.(lucas_manuel_chat.id, lucas.id, [
  {"Perfecto, gracias profe.\nBuen finde", "sent", 42},
])
create_messages.(lucas_manuel_chat.id, manuel.id, [
  {"Igualmente.", "sent", 41},
])

# Messages in CS2 group
create_messages.(cs2_chat.id, lucas.id, [
  {"Que ondaa, sale una partida??", "sent", 36},
  {"Ando re manija", "sent", 35}
])

create_messages.(cs2_chat.id, martin.id, [
  {"Banca que estoy mirando una serie", "sent", 34},
  {"Termino este episodio y entro", "sent", 33}
])

create_messages.(cs2_chat.id, lucas.id, [
  {"Dale que ayer bajé de rango, quiero volver", "sent", 32}
])

create_messages.(cs2_chat.id, martin.id, [
  {"Hoy se sube de nuevo chill", "sent", 31},
])
create_messages.(cs2_chat.id, manuel.id, [
  {"Yo en 20 entro aprox", "sent", 30},
  {"Si no subís de rango hoy, te desapruebo el TP", "sent", 29},
])
create_messages.(cs2_chat.id, matias.id, [
  {"Banco 👆", "sent", 28}
])
create_messages.(cs2_chat.id, lucas.id, [
  {"jasjajsjasj no dale", "sent", 27},
  {"no voy a pegar un tiro ahora", "delivered", 26},
  {"Bueno avisen, me voy jugando otra de mientras", "read", 25}
])
create_messages.(cs2_chat.id, martin.id, [
  {"Si lucas o yo nos taseamos a uno en la primer partida que juguemos los 4 nos aprueban con un 10 de una", "sent", 24},
])
create_messages.(cs2_chat.id, manuel.id, [
  {"jasjasj dale, pero si alguno termina negativo va un 4", "sent", 23},
])

# Messages in TP FINAL Taller Group
create_messages.(tp_final_taller_chat.id, lucas.id, [
  {"Mensaje viejísimo de prueba", "sent", 1000},
  {"Que les parece el logo que mandé?", "sent", 96},
  {"No sé si cambiar un poco el color del violeta", "sent", 95}
])

create_messages.(tp_final_taller_chat.id, martin.id, [
  {"quedo muy copado, me gusta me gusta:)", "sent", 94}
])

create_messages.(tp_final_taller_chat.id, rocio.id, [
  {"Si, está muy bueno! Combina bastante bien", "sent", 93},
  {"Capaz el azul podría ser un poquito más claro", "sent", 92}
])

create_messages.(tp_final_taller_chat.id, martin.id, [
  {"Sí puede ser", "sent", 91},
  {"Sino podrías hacer el violeta más oscuro para que contraste más", "sent", 90}
])

create_messages.(tp_final_taller_chat.id, rocio.id, [
  {"Sí, me gusta, si querés probalo así a ver como queda y después nos decís.\nIgual yo diría de no complicarnos tanto con esto, porque tampoco le van a prestar tanta atención, yo diría de cerrar rápido así ya nos ponemos bien con el back y con todo el tema de los registros", "sent", 89}
])

IO.puts("\n🎉 Seed data created successfully!")
IO.puts("📊 Summary:")
IO.puts("  👤 Users: #{length(created_users)}")
IO.puts("  🤝 Contacts: #{length(contacts)}")
IO.puts("  🚫 Blocked: #{length(blocked_contacts)}")
IO.puts("  💬 Chats: #{length(created_chats)} (2 group, 2 private)")
IO.puts("  👥 Chat Members: #{length(chat_members)}")
IO.puts("  📝 Messages: #{Repo.aggregate(Message, :count, :id)}")

IO.puts("\n🔑 Test credentials (all passwords: 12345678):")
IO.puts("  • lucas (Lucas Couttulenc)")
IO.puts("  • martin (Martin Maddalena)")
IO.puts("  • rocio (Rocío Gallo)")
IO.puts("  • manuel (Manuel Camejo)")
IO.puts("  • matias (Matías Onorato)")
