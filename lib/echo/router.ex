defmodule Echo.Router do
  @moduledoc """
  HTTP router for the Echo chat application.
  Handles incoming HTTP requests and returns responses.
  """

  import Plug.Conn

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
