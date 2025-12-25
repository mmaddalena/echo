defmodule Echo.Auth.TokenStore do
  use GenServer

  # Es un Genserver que sirve de registro,
  # guarda los tokens generados con el user_id correspondiente.
  # Como el token no lo generamos encriptando el user_id o algo por el estilo,
  # sino que es un numero aleatorio, necesitamos guardar la tupla.
  # Si hacemos una encriptación DECENTE, sería mucho más complejo al pedo.

  def init(_) do
    # Creamos un Map vacío como estado inicial
    # no me acuerdo bien la sintaxis de las callbacks, despues lo hago.
  end

  def put(token, user_id) do
    # Guarda la tupla en el estado
  end

  def get(token) do
    # Devuelve el user_id asignado al token
  end
end
