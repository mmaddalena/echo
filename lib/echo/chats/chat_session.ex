defmodule Echo.Chats.ChatSession do
  alias Echo.Chats.ChatSessionSup
  # Idem que el UserSession.
  # Es un Genserver que vive mientras la sesion del chat esté viva.
  # La sesión vive despues de x tiempo de inactividad.


  def send_message(chat_session_pid, user_id, body) do
    # Itera en cada user_id de los miembros del chat...
    # Creeria que crea un struct message del tipo del schema Message
    # Esta funcion la llama el userSession del emisor, viniendo del socket, desde el cliente.
    # Se fija si esta la usersession viva:
    # Si sí: le llama a userSession.recieve_message(message)
    # Si no: crea una notificacion para ese usuario y lo persiste.
  end
end
