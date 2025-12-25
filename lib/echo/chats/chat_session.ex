defmodule Echo.Chats.ChatSession do
  alias Echo.Chats.ChatSessionSup
  # Idem que el UserSession.
  # Es un Genserver que vive mientras la sesion del chat esté viva.
  # La sesión vive despues de x tiempo de inactividad.


  def send_message(chat_session_pid, user_id, body) do

  end
end
