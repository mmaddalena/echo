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
    "username" => "mario_santos",
    "password" => "12345678",
    "email" => "mariosantos@simulador",
    "name" => "Mario Santos",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/3edc8153-88a1-4a39-afc2-f006cd5ade19-024f8189-fcba-4b27-b2b0-c0f57bd6c574.jpg",
  },
  %{
    "username" => "emilio_ravenna",
    "password" => "12345678",
    "email" => "maximocossovich@simulador",
    "name" => "Máximo Cozzetti",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-eda3b2a7-c926-4958-930a-cd1f8c9a7e16.jpg",
  },
  %{
    "username" => "gabriel_medina",
    "password" => "12345678",
    "email" => "gabimedina@simulador",
    "name" => "Gabriel Medina",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-0a23bae5-db95-4d82-a56c-9226560b8da8.jpg",
  },
  %{
    "username" => "pablo_lampone",
    "password" => "12345678",
    "email" => "plampone@simulador",
    "name" => "Pablo Lampone",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-8a37430e-8546-4712-95f8-4403efbd836b.jpg",
  },
  %{
    "username" => "tamazaki",
    "password" => "12345678",
    "email" => "tamazaki@subsimulador",
    "name" => "Tamazaki",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-0a7cd3bb-89df-4ef3-938f-d0b45272b5f2.png",
  },
  %{
    "username" => "marcos_molero",
    "password" => "12345678",
    "email" => "marcos_molero_pd@capo",
    "name" => "Marcos Molero",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-7b7af017-3963-49df-89e5-40caf312d576.jpg",
  },
  %{
    "username" => "pp_argento",
    "password" => "12345678",
    "email" => "pepe_arg@arg",
    "name" => "Pepe Argento",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-2f810b36-d2ec-47ed-b1b8-51bc25b51dd7.jpg",
  },
  %{
    "username" => "wwhite",
    "password" => "12345678",
    "email" => "walterwhite@cooker",
    "name" => "Walter Hartwell White",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-be508e0d-b04e-433b-ae08-fe39025ddc8c.png",
  },
  %{
    "username" => "jesse_pinkman",
    "password" => "12345678",
    "email" => "jesse_pinkman@cooker",
    "name" => "Jesse Pinkman",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-cfc4f2e4-9ea7-4ecb-86f5-13f4cb5cd6b9.png",
  },
  %{
    "username" => "lucio_bonelli",
    "password" => "12345678",
    "email" => "lucio@simulador",
    "name" => "Lucio Bonelli",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-24bfba69-360f-40fa-b04b-a20e9888ef6e.jpg"
  },
  %{
    "username" => "feller",
    "password" => "12345678",
    "email" => "feller@simulador",
    "name" => "Feller",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-c4e5c2ec-5c72-43f7-9aca-24416a4ab2b5.jpg"
  },
  %{
    "username" => "martin_vanegas",
    "password" => "12345678",
    "email" => "vanegas@simulador",
    "name" => "Martín Vanegas",
    "avatar_url" => "https://storage.googleapis.com/echo-fiuba/avatars/users/5398cf4e-abb6-4226-9f38-487ae3c9bebb-60d545e8-04e9-4f60-9991-1eb5a751aee8.jpg"
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
users_by_username =
  Map.new(created_users, fn u -> {u.username, u} end)

lucas   = users_by_username["lucas"]
martin  = users_by_username["martin"]
mario_santos  = users_by_username["mario_santos"]
emilio_ravenna  = users_by_username["emilio_ravenna"]
pablo_lampone  = users_by_username["pablo_lampone"]
gabriel_medina  = users_by_username["gabriel_medina"]
tamazaki  = users_by_username["tamazaki"]
lucio_bonelli = users_by_username["lucio_bonelli"]
feller = users_by_username["feller"]
martin_vanegas = users_by_username["martin_vanegas"]
marcos_molero  = users_by_username["marcos_molero"]
pp_argento  = users_by_username["pp_argento"]
wwhite  = users_by_username["wwhite"]
jesse_pinkman  = users_by_username["jesse_pinkman"]



# Update last_seen_at for more realistic data (truncate microseconds)
now = truncate_datetime.(DateTime.utc_now())
one_hour_ago = truncate_datetime.(DateTime.add(now, -3600, :second))
three_hours_ago = truncate_datetime.(DateTime.add(now, -10800, :second))
yesterday = truncate_datetime.(DateTime.add(now, -86400, :second))

Repo.get!(User, mario_santos.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, emilio_ravenna.id) |> Ecto.Changeset.change(last_seen_at: one_hour_ago) |> Repo.update!()
Repo.get!(User, pablo_lampone.id) |> Ecto.Changeset.change(last_seen_at: three_hours_ago) |> Repo.update!()
Repo.get!(User, gabriel_medina.id) |> Ecto.Changeset.change(last_seen_at: yesterday) |> Repo.update!()

Repo.get!(User, wwhite.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, jesse_pinkman.id) |> Ecto.Changeset.change(last_seen_at: one_hour_ago) |> Repo.update!()

Repo.get!(User, tamazaki.id) |> Ecto.Changeset.change(last_seen_at: yesterday) |> Repo.update!()
Repo.get!(User, lucio_bonelli.id) |> Ecto.Changeset.change(last_seen_at: three_hours_ago) |> Repo.update!()
Repo.get!(User, feller.id) |> Ecto.Changeset.change(last_seen_at: yesterday) |> Repo.update!()
Repo.get!(User, martin_vanegas.id) |> Ecto.Changeset.change(last_seen_at: one_hour_ago) |> Repo.update!()

# Create contacts
IO.puts("🤝 Creating contacts...")

contacts = [
  # Lucas's contacts
  %{user_id: lucas.id, contact_id: martin.id, nickname: "Marto"},
  %{user_id: lucas.id, contact_id: jesse_pinkman.id, nickname: "Jesse"},
  # Martin's contacts
  %{user_id: martin.id, contact_id: lucas.id, nickname: "Luquitas"},
  %{user_id: martin.id, contact_id: jesse_pinkman.id, nickname: nil},
  # mario_santos's contacts
  %{user_id: mario_santos.id, contact_id: emilio_ravenna.id, nickname: "Ravenna"},
  %{user_id: mario_santos.id, contact_id: pablo_lampone.id, nickname: "Lampone"},
  %{user_id: mario_santos.id, contact_id: gabriel_medina.id, nickname: "Medina"},
  %{user_id: mario_santos.id, contact_id: marcos_molero.id, nickname: "Molero"},
  # emilio_ravenna's contacts
  %{user_id: emilio_ravenna.id, contact_id: mario_santos.id, nickname: "Marito"},
  %{user_id: emilio_ravenna.id, contact_id: pablo_lampone.id, nickname: "Cinthia Lampone"},
  %{user_id: emilio_ravenna.id, contact_id: gabriel_medina.id, nickname: "Medina"},
  # pablo_lampone's contacts
  %{user_id: pablo_lampone.id, contact_id: mario_santos.id, nickname: "Mario"},
  %{user_id: pablo_lampone.id, contact_id: emilio_ravenna.id, nickname: "Emilio"},
  %{user_id: pablo_lampone.id, contact_id: gabriel_medina.id, nickname: "Gabriel"},
  # gabriel_medina's contacts
  %{user_id: gabriel_medina.id, contact_id: mario_santos.id, nickname: "Mar"},
  %{user_id: gabriel_medina.id, contact_id: pablo_lampone.id, nickname: "Camaleón"},
  %{user_id: gabriel_medina.id, contact_id: emilio_ravenna.id, nickname: "Pablín"},
  # wwhite's contacts
  %{user_id: wwhite.id, contact_id: jesse_pinkman.id, nickname: "Jesse"},
  # jesse_pinkman's contacts
  %{user_id: jesse_pinkman.id, contact_id: wwhite.id, nickname: "Mister White"},
]

Enum.each(contacts, fn contact_attrs ->
  %Contact{}
  |> Contact.changeset(contact_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(contacts)} contacts created")

# Create chats
IO.puts("💬 Creating chats...")

# Direct chats (private)
direct_chats = [
  %{name: nil, type: "private", creator_id: lucas.id}, # Lucas ↔ Martin
  %{name: nil, type: "private", creator_id: pablo_lampone.id}, # Lampone ↔ Ravenna
  %{name: nil, type: "private", creator_id: pablo_lampone.id}, # Lampone ↔ Medina
  %{name: nil, type: "private", creator_id: wwhite.id},        # Walter ↔ Jesse
  %{name: nil, type: "private", creator_id: mario_santos.id}   # Mario ↔ Molero
]

# Group chats
group_chats = [
  %{
    name: "CS2",
    type: "group",
    creator_id: lucas.id,
    avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/3edc8153-88a1-4a39-afc2-f006cd5ade19-7daea6ab-a679-4fdb-b147-80e018bf94e7.png"
  },
  %{
    name: "TP FINAL Taller",
    type: "group",
    creator_id: martin.id,
    avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/3edc8153-88a1-4a39-afc2-f006cd5ade19-533d0965-dd99-4c27-a452-8afed768aa6c.jpg"
  },
  %{
    name: "Los Simuladores",
    type: "group",
    creator_id: mario_santos.id,
    avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/3edc8153-88a1-4a39-afc2-f006cd5ade19-0d7d4f22-5505-47c9-af4d-d29714d7905e.jpg"
  },
  %{
    name: "Operativo Completo",
    type: "group",
    creator_id: mario_santos.id,
    avatar_url: "https://storage.googleapis.com/echo-fiuba/avatars/users/3edc8153-88a1-4a39-afc2-f006cd5ade19-96a4d893-7710-4ddf-8e70-01019837f442.jpg"
  }
]

all_chats = direct_chats ++ group_chats

created_chats = Enum.map(all_chats, fn chat_attrs ->
  %Chat{}
  |> Chat.changeset(chat_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(created_chats)} chats created")

# Map chats for reference
[
  lucas_martin_chat,
  lampone_ravenna_chat,
  lampone_medina_chat,
  walter_jesse_chat,
  mario_molero_chat,
  cs2_chat,
  tp_final_taller_chat,
  simuladores_chat,
  operativo_chat
] = created_chats

# Create chat members
IO.puts("👥 Adding members to chats...")

chat_members = [
  # Direct chat: Lucas ↔ Martin
  %{chat_id: lucas_martin_chat.id, user_id: lucas.id},
  %{chat_id: lucas_martin_chat.id, user_id: martin.id},

  # Direct chat: Lampone ↔ Ravenna
  %{chat_id: lampone_ravenna_chat.id, user_id: pablo_lampone.id},
  %{chat_id: lampone_ravenna_chat.id, user_id: emilio_ravenna.id},

  # Direct chat: Lampone ↔ Medina
  %{chat_id: lampone_medina_chat.id, user_id: pablo_lampone.id},
  %{chat_id: lampone_medina_chat.id, user_id: gabriel_medina.id},

  # Direct chat: Walter ↔ Jesse
  %{chat_id: walter_jesse_chat.id, user_id: wwhite.id},
  %{chat_id: walter_jesse_chat.id, user_id: jesse_pinkman.id},

  # Direct chat: Mario ↔ Molero
  %{chat_id: mario_molero_chat.id, user_id: mario_santos.id},
  %{chat_id: mario_molero_chat.id, user_id: marcos_molero.id},

  # Group chat: Los Simuladores
  %{chat_id: simuladores_chat.id, user_id: mario_santos.id, role: "admin"},
  %{chat_id: simuladores_chat.id, user_id: emilio_ravenna.id},
  %{chat_id: simuladores_chat.id, user_id: pablo_lampone.id},
  %{chat_id: simuladores_chat.id, user_id: gabriel_medina.id},

  # Group chat: Operativo Completo
  %{chat_id: operativo_chat.id, user_id: mario_santos.id, role: "admin"},
  %{chat_id: operativo_chat.id, user_id: emilio_ravenna.id},
  %{chat_id: operativo_chat.id, user_id: pablo_lampone.id},
  %{chat_id: operativo_chat.id, user_id: gabriel_medina.id},
  %{chat_id: operativo_chat.id, user_id: tamazaki.id},
  %{chat_id: operativo_chat.id, user_id: lucio_bonelli.id},
  %{chat_id: operativo_chat.id, user_id: feller.id},
  %{chat_id: operativo_chat.id, user_id: martin_vanegas.id},

  # Group chat: TP FINAL Taller (Lucas, Martin)
  %{chat_id: tp_final_taller_chat.id, user_id: lucas.id, role: "admin"},
  %{chat_id: tp_final_taller_chat.id, user_id: martin.id},

  # Group chat: CS (Lucas, Martin)
  %{chat_id: cs2_chat.id, user_id: lucas.id, role: "admin"},
  %{chat_id: cs2_chat.id, user_id: martin.id}
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

# Messages in Lampone ↔ Ravenna chat
create_messages.(lampone_ravenna_chat.id, pablo_lampone.id, [
  {"Emilio, tenemos un problema.", "read", 20},
  {"Hay que apretar a un tipo.", "read", 19}
])
create_messages.(lampone_ravenna_chat.id, emilio_ravenna.id, [
  {"Pará, primero entendamos la situación.", "read", 18},
  {"No siempre es a los golpes.", "read", 17}
])

# Messages in Lampone ↔ Medina chat
create_messages.(lampone_medina_chat.id, gabriel_medina.id, [
  {"Pablo, necesito que mantengas la calma.", "read", 16}
])
create_messages.(lampone_medina_chat.id, pablo_lampone.id, [
  {"Yo estoy calmado.", "read", 15},
  {"Pero listo para actuar.", "delivered", 1}
])

# Messages in Walter ↔ Jesse chat
create_messages.(walter_jesse_chat.id, wwhite.id, [
  {"Jesse, we need to cook. (léase con voz de Walter)", "read", 10},
  {"Esta vez sin errores.", "read", 9}
])
create_messages.(walter_jesse_chat.id, jesse_pinkman.id, [
  {"Yo nunca cometo errores, Mr. White.", "read", 8},
  {"Bueno... casi nunca.", "delivered", 2}
])

# Messages in Mario ↔ Molero chat
create_messages.(mario_molero_chat.id, mario_santos.id, [
  {"Molero, investigá a este sujeto.", "read", 14}
])
create_messages.(mario_molero_chat.id, marcos_molero.id, [
  {"Ya estoy en eso.", "read", 13},
  {"En unas horas tengo todo.", "read", 12}
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
  {"Yo en 20 entro aprox", "sent", 30},
  {"Si no subís de rango hoy, te desapruebo el TP", "sent", 29},
])
create_messages.(cs2_chat.id, lucas.id, [
  {"Bueno avisa, me voy jugando otra de mientras", "read", 25}
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
create_messages.(tp_final_taller_chat.id, martin.id, [
  {"Sí puede ser", "sent", 91},
  {"Sino podrías hacer el violeta más oscuro para que contraste más", "sent", 90}
])

# Messages in Los Simuladores group
create_messages.(simuladores_chat.id, mario_santos.id, [
  {"Tenemos un nuevo caso.", "read", 24}
])
create_messages.(simuladores_chat.id, emilio_ravenna.id, [
  {"¿De qué tipo?", "read", 23}
])
create_messages.(simuladores_chat.id, pablo_lampone.id, [
  {"Si hay que apretar a alguien, yo me encargo.", "read", 22}
])
create_messages.(simuladores_chat.id, gabriel_medina.id, [
  {"Tranquilos. Pensemos primero.", "read", 21}
])

# Messages in Operativo Completo group
create_messages.(operativo_chat.id, mario_santos.id, [
  {"Equipo completo, arrancamos mañana.", "read", 30}
])
create_messages.(operativo_chat.id, lucio_bonelli.id, [
  {"Antecedentes revisados.", "read", 29}
])
create_messages.(operativo_chat.id, feller.id, [
  {"El contacto está asegurado.", "read", 28}
])
create_messages.(operativo_chat.id, martin_vanegas.id, [
  {"La logística está lista.", "read", 27}
])
create_messages.(operativo_chat.id, tamazaki.id, [
  {"Transporte confirmado.", "delivered", 3}
])


IO.puts("\n🎉 Seed data created successfully!")
IO.puts("📊 Summary:")
IO.puts("  👤 Users: #{length(created_users)}")
IO.puts("  🤝 Contacts: #{length(contacts)}")
IO.puts("  💬 Chats: #{length(created_chats)} (2 group, 2 private)")
IO.puts("  👥 Chat Members: #{length(chat_members)}")
IO.puts("  📝 Messages: #{Repo.aggregate(Message, :count, :id)}")

IO.puts("\n🔑 Test credentials (all passwords: 12345678):")
IO.puts("  • lucas")
IO.puts("  • martin")
IO.puts("  • mario_santos")
IO.puts("  • emilio_ravenna")
IO.puts("  • pablo_lampone")
IO.puts("  • gabriel_medina")
IO.puts("  • wwhite")
IO.puts("  • jesse_pinkman")
