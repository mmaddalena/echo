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
    "password_hash" => "12345678",
    "email" => "lucas@coutt.com",
    "name" => "Lucas Couttulenc",
  },
  %{
    "username" => "martin",
    "password_hash" => "12345678",
    "email" => "martin@maddalena.com",
    "name" => "Martin Maddalena",
  },
  %{
    "username" => "rocio",
    "password_hash" => "12345678",
    "email" => "rocio@gallo.com",
    "name" => "Rocío Gallo",
  },
  %{
    "username" => "manuel",
    "password_hash" => "12345678",
    "email" => "manuel@camejo.com",
    "name" => "Manuel Camejo",
  },
  %{
    "username" => "matias",
    "password_hash" => "12345678",
    "email" => "matias@onorato.com",
    "name" => "Matías Onorato",
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
  %{user_id: martin.id, contact_id: manuel.id, nickname: "Manu"},
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
]

# Group chats
group_chats = [
  %{name: "CS GO", type: "group", creator_id: lucas.id},
  %{name: "TP FINAL Taller", type: "group", creator_id: martin.id}
]

all_chats = direct_chats ++ group_chats

created_chats = Enum.map(all_chats, fn chat_attrs ->
  %Chat{}
  |> Chat.changeset(chat_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(created_chats)} chats created")

# Map chats for reference
[lucas_martin_chat, cs_go_chat, tp_final_taller_chat] = created_chats

# Create chat members
IO.puts("👥 Adding members to chats...")

chat_members = [
  # Direct chat: Lucas ↔ Martin
  %{chat_id: lucas_martin_chat.id, user_id: lucas.id},
  %{chat_id: lucas_martin_chat.id, user_id: martin.id},

  # Group chat: TP FINAL Taller (Lucas, Martin, Rocio)
  %{chat_id: tp_final_taller_chat.id, user_id: lucas.id},
  %{chat_id: tp_final_taller_chat.id, user_id: martin.id},
  %{chat_id: tp_final_taller_chat.id, user_id: rocio.id}
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
  Enum.map(message_data, fn {content, hours_ago} ->
    inserted_at = truncate_datetime.(DateTime.add(DateTime.utc_now(), -hours_ago * 3600, :second))

    %Message{}
    |> Message.changeset(%{
      chat_id: chat_id,
      user_id: sender_id,
      content: content
    })
    |> Ecto.Changeset.change(inserted_at: inserted_at, updated_at: inserted_at)
    |> Repo.insert!()
  end)
end

# Messages in Lucas ↔ Martin chat
create_messages.(lucas_martin_chat.id, lucas.id, [
  {"Que onda Martin?", 48},
  {"Todo bien??", 48}
])

create_messages.(lucas_martin_chat.id, martin.id, [
  {"Holaaa", 47},
  {"Todo bien y vos?", 46}
])
create_messages.(lucas_martin_chat.id, lucas.id, [
  {"Bien bien, metiendole al TP", 45},
  {"Hacemos call para seguir con las features que faltan?", 44}
])
create_messages.(lucas_martin_chat.id, martin.id, [
  {"Dale, ahí me meto a Discord", 43}
])

# Messages in CS GO group
create_messages.(cs_go_chat.id, lucas.id, [
  {"Que ondaa, sale una partida??", 36},
  {"Ando re manija", 35}
])

create_messages.(cs_go_chat.id, martin.id, [
  {"Esta ehhh, banca que ando mirando una serie", 34},
  {"Termino este episodio y me meto", 34}
])

# Messages in TP FINAL Taller Group
create_messages.(tp_final_taller_chat.id, lucas.id, [
  {"Que les parece el logo que diseñamos?", 96}
])

create_messages.(tp_final_taller_chat.id, martin.id, [
  {"quedo muy copado, me gusta me gusta:)", 95}
])

create_messages.(tp_final_taller_chat.id, rocio.id, [
  {"Si, está muy bueno! Combina bastante bien", 93}
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
