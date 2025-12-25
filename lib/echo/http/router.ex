defmodule Echo.Http.Router do
  @moduledoc """
  HTTP router for the Echo chat application.
  Handles incoming HTTP requests and returns responses.
  """

  import Plug.Conn

  defp extract_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, :token_missing}
    end
  end

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    route(conn, conn.method, conn.request_path)
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
         {:ok, token} <- Echo.Auth.Accounts.login(u, p)
    do
      send_resp(conn, 200, Jason.encode!(%{token: token}))
    else
      _ -> send_resp(conn, 401, "Invalid credentials")
    end
  end


  defp route(conn, "POST", "/api/message") do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, %{"chat_id" => chat_id, "text" => text}} <- Jason.decode(body),
         {:ok, token} <- extract_token(conn),
         {:ok, result} <- Echo.Messages.send_message(token, chat_id, text)
    do
      send_resp(conn, 200, Jason.encode!(result))
    else
      {:error, :token_missing} -> send_resp(conn, 401, "Token Missing")
      {:error, reason} -> send_resp(conn, 400, Jason.encode!(%{error: reason}))
    end
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
