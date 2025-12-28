defmodule Echo.Chats.ChatSession do
  alias Echo.Chats.ChatSessionSup
  # Idem que el UserSession.
  # Es un Genserver que vive mientras la sesion del chat esté viva.
  # La sesión vive despues de x tiempo de inactividad.


  use GenServer

  def start_link(chat_id) do
    GenServer.start_link(
      __MODULE__,
      chat_id,
      name: {:via, Registry, {Echo.ProcessRegistry, {:chat, chat_id}}}
    )
  end

  @impl true
  def init(chat_id) do
    {:ok, %{chat_id: chat_id}} # TODO: Mandarle un msj a si mismo para que levante la info necesaria para cargarse todo al estado.
  end


  def send_message(chat_session_pid, user_id, client_msg_id, body) do
    # Itera en cada user_id de los miembros del chat...
    # Creeria que crea un struct message del tipo del schema Message
    # Esta funcion la llama el userSession del emisor, viniendo del socket, desde el cliente.
    # Le llama al userSession.message.sent(message) del emisor. (message es un map con la info del msg (que también contiene el client_msg_id)))
    # Se fija si esta la usersession viva:
    # Si sí: le llama a userSession.recieve_message (ACA NO MANDA EL client_msg_id, porque los receptores no lo necesitan)
    # Si no: crea una notificacion para ese usuario y lo persiste.
  end
end
