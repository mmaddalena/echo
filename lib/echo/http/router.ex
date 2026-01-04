defmodule Echo.Http.Router do
  @moduledoc """
  HTTP router for the Echo chat application.
  Handles incoming HTTP requests and returns responses.
  """

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> CORSPlug.call(cors_opts())
    |> route(conn.method, conn.request_path)
  end

  defp cors_opts do
    CORSPlug.init(
      origin: ["http://localhost:5173"],
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      headers: ["Content-Type", "Authorization"]
    )
  end


  # Route for GET /
  defp route(conn, "GET", "/") do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_response())
  end

  # Route for GET /api/health
  defp route(conn, "GET", "/api/health") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"status": "ok"}))
  end

  defp route(conn, "POST", "/api/login") do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, %{"username" => u, "password" => p}} <- Jason.decode(body),
         {:ok, token} <- Echo.Auth.Accounts.login(u, p) do
          #IO.puts("body: #{body}\n User: #{u}\n pass: #{p}\n token: #{token}")
      send_resp(conn, 200, Jason.encode!(%{token: token}))
    else
      {:error, :user_not_found} ->
        send_resp(conn, 401, Jason.encode!(%{error: "User not found"}))

      {:error, :invalid_password} ->
        send_resp(conn, 401, Jason.encode!(%{error: "Invalid password"}))

      _ ->
        send_resp(conn, 401, Jason.encode!(%{error: "Invalid credentials"}))
    end
  end

  defp route(conn, "POST", "/api/register") do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, %{"username" => u, "password" => p, "name" => name}} <- Jason.decode(body),
         email = Map.get(body, "email", nil),
         {:ok, token} <- Echo.Auth.Accounts.register(u, p, name, email) do
      send_resp(conn, 201, Jason.encode!(%{token: token}))
    else
      {:error, :username_taken} ->
        send_resp(conn, 409, Jason.encode!(%{error: "Username already taken"}))

      {:error, changeset} when is_map(changeset) ->
        errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        send_resp(conn, 400, Jason.encode!(%{error: "Validation failed", details: errors}))

      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Registration failed"}))
    end
  end





  # Helper para errores de Ecto (si usas base de datos)
  defp translate_error({msg, opts}) do
    # Implementación básica - puedes expandir esto
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end




  # Fallback for unmapped routes
  defp route(conn, _method, _path) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, ~s({"error": "Not found"}))
  end

  defp html_response do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Echo Chat App</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 10px;
          box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
          text-align: center;
        }
        h1 {
          color: #667eea;
          margin: 0;
        }
        p {
          color: #666;
          margin-top: 10px;
        }
        .status {
          margin-top: 20px;
          padding: 10px;
          background: #f0f0f0;
          border-radius: 5px;
          font-family: monospace;
          color: #27ae60;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🎵 Echo Chat App</h1>
        <p>Welcome to Echo - Your Real-time Chat Application</p>
        <div class="status">✓ Server is running</div>
      </div>
    </body>
    </html>
    """
  end



end
