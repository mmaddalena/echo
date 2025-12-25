defmodule Echo.Users.UserSession do
  # Es un genserver que maneja toda la sesion del usuario.
  # Se crea cuando el usuario se logea, y vive hasta que se logoutea o
  # hasta que pase x tiempo de inactividad.


  # En su estado guarda cosas de rápido y frecuente acceso como:
  # id del usuario,
  # últimos n mensajes,
  # last activity,
  # last_chat_opened_id
  # texto escrito pero no mandado (en borrador)
    # (este no deberia estar aca, porque un usuario podria tener un borrador en mas de un chat igual)
end
