# seeds.exs
alias Echo.Repo
alias Echo.Schemas.{User, Contact, Chat, ChatMember, Message, Notification, BlockedContact}
import Ecto.Query

# Helper function to truncate microseconds
truncate_datetime = fn datetime ->
  DateTime.truncate(datetime, :second)
end

# Clear existing data
IO.puts("🗑️  Clearing existing data...")

Repo.delete_all(Notification)
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
    "password_hash" => "12345678",  # Note: This should be hashed in your changeset
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
    "username" => "juan",
    "password_hash" => "12345678",
    "email" => "juan@perez.com",
    "name" => "Juan Pérez",
  },
  %{
    "username" => "maria",
    "password_hash" => "12345678",
    "email" => "maria@gomez.com",
    "name" => "María Gómez",
  },
  %{
    "username" => "pedro",
    "password_hash" => "12345678",
    "email" => "pedro@rodriguez.com",
    "name" => "Pedro Rodríguez",
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
[lucas, martin, juan, maria, pedro] = created_users

# Update last_seen_at for more realistic data (truncate microseconds)
now = truncate_datetime.(DateTime.utc_now())
yesterday = truncate_datetime.(DateTime.add(now, -86400, :second))
two_hours_ago = truncate_datetime.(DateTime.add(now, -7200, :second))

Repo.get!(User, lucas.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, martin.id) |> Ecto.Changeset.change(last_seen_at: yesterday) |> Repo.update!()
Repo.get!(User, juan.id) |> Ecto.Changeset.change(last_seen_at: two_hours_ago) |> Repo.update!()
Repo.get!(User, maria.id) |> Ecto.Changeset.change(last_seen_at: now) |> Repo.update!()
Repo.get!(User, pedro.id) |> Ecto.Changeset.change(last_seen_at: two_hours_ago) |> Repo.update!()

# Create contacts (friendships)
IO.puts("🤝 Creating contacts...")

contacts = [
  # Lucas's contacts
  %{user_id: lucas.id, contact_id: martin.id, nickname: "Marto"},
  %{user_id: lucas.id, contact_id: juan.id, nickname: "Juancito"},
  %{user_id: lucas.id, contact_id: maria.id, nickname: "Mari"},
  # Martin's contacts
  %{user_id: martin.id, contact_id: lucas.id, nickname: "Luquitas"},
  %{user_id: martin.id, contact_id: juan.id, nickname: "Juancito"},
  %{user_id: martin.id, contact_id: pedro.id, nickname: "Pedrito"},
  # Juan's contacts
  %{user_id: juan.id, contact_id: lucas.id, nickname: "Lucasss"},
  %{user_id: juan.id, contact_id: martin.id, nickname: "Marto"},
  %{user_id: juan.id, contact_id: maria.id, nickname: "Mary"},
  # Maria's contacts
  %{user_id: maria.id, contact_id: lucas.id, nickname: "Luke"},
  %{user_id: maria.id, contact_id: juan.id, nickname: "Juancito"},
  %{user_id: maria.id, contact_id: pedro.id, nickname: "Pedrito"},
  # Pedro's contacts
  %{user_id: pedro.id, contact_id: martin.id, nickname: "Martín"},
  %{user_id: pedro.id, contact_id: maria.id, nickname: "Maru"}
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
  # Juan blocked Pedro
  %{blocker_id: juan.id, blocked_id: pedro.id},
  # Maria blocked Martin
  %{blocker_id: maria.id, blocked_id: martin.id}
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
  %{name: nil, type: "private", creator_id: lucas.id}, # Lucas ↔ Juan
  %{name: nil, type: "private", creator_id: martin.id}, # Martin ↔ Pedro
  %{name: nil, type: "private", creator_id: juan.id}, # Juan ↔ Maria
]

# Group chats
group_chats = [
  %{name: "Work Team", type: "group", creator_id: lucas.id},
  %{name: "Friends Group", type: "group", creator_id: martin.id},
  %{name: "Project Alpha", type: "group", creator_id: maria.id}
]

all_chats = direct_chats ++ group_chats

created_chats = Enum.map(all_chats, fn chat_attrs ->
  %Chat{}
  |> Chat.changeset(chat_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(created_chats)} chats created")

# Map chats for reference
[lucas_martin_chat, lucas_juan_chat, martin_pedro_chat, juan_maria_chat, work_team_chat, friends_group_chat, project_alpha_chat] = created_chats

# Create chat members
IO.puts("👥 Adding members to chats...")

chat_members = [
  # Direct chat: Lucas ↔ Martin
  %{chat_id: lucas_martin_chat.id, user_id: lucas.id},
  %{chat_id: lucas_martin_chat.id, user_id: martin.id},

  # Direct chat: Lucas ↔ Juan
  %{chat_id: lucas_juan_chat.id, user_id: lucas.id},
  %{chat_id: lucas_juan_chat.id, user_id: juan.id},

  # Direct chat: Martin ↔ Pedro
  %{chat_id: martin_pedro_chat.id, user_id: martin.id},
  %{chat_id: martin_pedro_chat.id, user_id: pedro.id},

  # Direct chat: Juan ↔ Maria
  %{chat_id: juan_maria_chat.id, user_id: juan.id},
  %{chat_id: juan_maria_chat.id, user_id: maria.id},

  # Group chat: Work Team (Lucas, Martin, Maria)
  %{chat_id: work_team_chat.id, user_id: lucas.id},
  %{chat_id: work_team_chat.id, user_id: martin.id},
  %{chat_id: work_team_chat.id, user_id: maria.id},

  # Group chat: Friends Group (Lucas, Martin, Juan, Pedro)
  %{chat_id: friends_group_chat.id, user_id: lucas.id},
  %{chat_id: friends_group_chat.id, user_id: martin.id},
  %{chat_id: friends_group_chat.id, user_id: juan.id},
  %{chat_id: friends_group_chat.id, user_id: pedro.id},

  # Group chat: Project Alpha (Juan, Maria, Pedro)
  %{chat_id: project_alpha_chat.id, user_id: juan.id},
  %{chat_id: project_alpha_chat.id, user_id: maria.id},
  %{chat_id: project_alpha_chat.id, user_id: pedro.id}
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
  {"Hey Martin! How are you?", 48},
  {"Did you finish the project?", 46}
])

create_messages.(lucas_martin_chat.id, martin.id, [
  {"Hi Lucas! I'm good, thanks!", 47},
  {"Almost done, just need to review it", 45},
  {"Can we meet tomorrow?", 44}
])

create_messages.(lucas_martin_chat.id, lucas.id, [
  {"Sure, 2 PM works?", 43},
  {"Bring the reports please", 42}
])

# Messages in Lucas ↔ Juan chat
create_messages.(lucas_juan_chat.id, lucas.id, [
  {"Juan, did you see the email?", 72}
])

create_messages.(lucas_juan_chat.id, juan.id, [
  {"Yes, I'll reply in a bit", 71},
  {"The budget looks good", 70}
])

# Messages in Martin ↔ Pedro chat
create_messages.(martin_pedro_chat.id, martin.id, [
  {"Pedro, are we still on for lunch?", 24}
])

create_messages.(martin_pedro_chat.id, pedro.id, [
  {"Yes! 1 PM at the usual place", 23},
  {"I'll bring the documents", 22}
])

# Messages in Juan ↔ Maria chat
create_messages.(juan_maria_chat.id, juan.id, [
  {"Maria, I need your feedback on the design", 12}
])

create_messages.(juan_maria_chat.id, maria.id, [
  {"I'll review it this afternoon", 11},
  {"Looks promising so far!", 10}
])

# Messages in Work Team group
create_messages.(work_team_chat.id, lucas.id, [
  {"Good morning team!", 36},
  {"Let's have a quick sync at 10 AM", 35}
])

create_messages.(work_team_chat.id, martin.id, [
  {"I can't make it at 10, how about 11?", 34}
])

create_messages.(work_team_chat.id, maria.id, [
  {"11 works for me", 33},
  {"I'll share the agenda", 32}
])

create_messages.(work_team_chat.id, lucas.id, [
  {"Perfect, 11 AM it is", 31}
])

# Messages in Friends Group
create_messages.(friends_group_chat.id, martin.id, [
  {"Who's up for the game on Saturday?", 96}
])

create_messages.(friends_group_chat.id, juan.id, [
  {"I'm in!", 95},
  {"What time?", 94}
])

create_messages.(friends_group_chat.id, lucas.id, [
  {"Count me in too", 93},
  {"8 PM?", 92}
])

create_messages.(friends_group_chat.id, pedro.id, [
  {"Can't make it this week, sorry guys", 91}
])

# Messages in Project Alpha group
create_messages.(project_alpha_chat.id, maria.id, [
  {"I've uploaded the initial wireframes", 60}
])

create_messages.(project_alpha_chat.id, juan.id, [
  {"Great! I'll review them", 59},
  {"Pedro, what's the status on the backend?", 58}
])

create_messages.(project_alpha_chat.id, pedro.id, [
  {"Almost done with the API endpoints", 57},
  {"Should be ready by tomorrow", 56}
])

# Create a deleted message (truncate microseconds)
deleted_message =
  %Message{}
  |> Message.changeset(%{
    chat_id: lucas_martin_chat.id,
    user_id: lucas.id,
    content: "This message will be deleted",
    deleted_at: truncate_datetime.(DateTime.utc_now())
  })
  |> Repo.insert!()

IO.puts("✅ Messages created (including 1 deleted message)")

# Create notifications
IO.puts("🔔 Creating notifications...")

# Get some messages for notifications
recent_message = Repo.one(from m in Message, order_by: [desc: m.inserted_at], limit: 1)
older_message = Repo.one(from m in Message, where: m.chat_id == ^work_team_chat.id, order_by: [asc: m.inserted_at], limit: 1)

notifications = [
  # Unread notification for Martin
  %{
    user_id: martin.id,
    chat_id: lucas_martin_chat.id,
    message_id: recent_message.id,
    read_at: nil
  },
  # Read notification for Lucas
  %{
    user_id: lucas.id,
    chat_id: work_team_chat.id,
    message_id: older_message.id,
    read_at: truncate_datetime.(DateTime.add(DateTime.utc_now(), -1, :hour))
  },
  # Unread notification for Maria
  %{
    user_id: maria.id,
    chat_id: project_alpha_chat.id,
    message_id: recent_message.id,
    read_at: nil
  },
  # Unread notification for Juan
  %{
    user_id: juan.id,
    chat_id: juan_maria_chat.id,
    message_id: recent_message.id,
    read_at: nil
  }
]

Enum.each(notifications, fn notification_attrs ->
  inserted_at = truncate_datetime.(DateTime.add(DateTime.utc_now(), -2, :hour))

  %Notification{}
  |> Notification.changeset(notification_attrs)
  |> Ecto.Changeset.change(inserted_at: inserted_at)
  |> Repo.insert!()
end)

IO.puts("✅ #{length(notifications)} notifications created")

IO.puts("\n🎉 Seed data created successfully!")
IO.puts("📊 Summary:")
IO.puts("  👤 Users: #{length(created_users)}")
IO.puts("  🤝 Contacts: #{length(contacts)}")
IO.puts("  🚫 Blocked: #{length(blocked_contacts)}")
IO.puts("  💬 Chats: #{length(created_chats)} (3 group, 4 private)")
IO.puts("  👥 Chat Members: #{length(chat_members)}")
IO.puts("  📝 Messages: #{Repo.aggregate(Message, :count, :id)}")
IO.puts("  🔔 Notifications: #{length(notifications)}")

IO.puts("\n🔑 Test credentials (all passwords: 12345678):")
IO.puts("  • lucas (Lucas Couttulenc)")
IO.puts("  • martin (Martin Maddalena)")
IO.puts("  • juan (Juan Pérez)")
IO.puts("  • maria (María Gómez)")
IO.puts("  • pedro (Pedro Rodríguez)")
