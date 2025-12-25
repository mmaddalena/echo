
defmodule Echo.Messages.Messages do


  def send_message(token, chat_id, body) do
    with {:ok, user_id} <- Auth.verify_token(token),
         {:ok, _session} <- UserSessionSup.get_or_start(user_id),
         {:ok, chat_session} <- ChatSessionSup.get_or_start(chat_id)
    do
      ChatSession.send_message(chat_session, user_id, body)
    end
  end


end
