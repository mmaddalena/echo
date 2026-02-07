defmodule Echo.Http.Router do
  @moduledoc """
  HTTP router for the Echo chat application.
  Serves API routes and the Vue SPA frontend.
  """

  import Plug.Conn

  ## -------- Plug entrypoint --------

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = CORSPlug.call(conn, cors_opts())

    if conn.halted do
      conn
    else
      conn
      # |> serve_static()
      |> route(conn.method, conn.request_path)
    end
  end

  ## -------- Static frontend (Vue) --------

  # defp serve_static(conn) do
  #   Plug.Static.call(
  #     conn,
  #     Plug.Static.init(
  #       at: "/",
  #       from: {:echo, "priv/static"},
  #       gzip: false,
  #       only: ~w(index.html assets favicon.ico)
  #     )
  #   )
  # end

  ## -------- CORS --------

  defp cors_opts do
    CORSPlug.init(
      origin: [
        "http://localhost:5173",
        "https://*.onrender.com"
      ],
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      headers: ["Content-Type", "Authorization"]
    )
  end

  ## -------- API routes --------

  defp route(conn, "GET", "/api/health") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"status":"ok"}))
  end

  defp route(conn, "POST", "/api/login") do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, %{"username" => u, "password" => p}} <- Jason.decode(body),
         {:ok, token} <- Echo.Auth.Accounts.login(u, p) do
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
    opts =
      Plug.Parsers.init(
        parsers: [:multipart],
        pass: ["*/*"],
        length: 10_000_000
      )

    conn = Plug.Parsers.call(conn, opts)

    case Echo.Auth.Accounts.register(conn.params) do
      {:ok, token} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(%{token: token}))

      {:error, :username_taken} ->
        send_resp(conn, 409, Jason.encode!(%{error: "Username already taken"}))

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  defp route(conn, "POST", "/api/users/me/avatar") do
    auth_header = List.first(get_req_header(conn, "authorization")) || ""
    token = String.replace(auth_header, "Bearer ", "")

    with {:ok, user_id} <- Echo.Auth.JWT.extract_user_id(token),
         {:ok, upload, conn} <- parse_multipart(conn),
         {:ok, user} <- Echo.Media.upload_user_avatar(user_id, upload) do
      send_resp(conn, 200, Jason.encode!(%{avatar_url: user.avatar_url}))
    else
      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Avatar upload failed"}))
    end
  end

  defp route(conn, "POST", "/api/groups/" <> rest) do
  case String.split(rest, "/") do
    [group_id, "avatar"] ->
      handle_group_avatar_upload(conn, group_id)

    _ ->
      send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end

  defp route(conn, "POST", "/api/chat/upload") do
    auth_header = List.first(get_req_header(conn, "authorization")) || ""
    token = String.replace(auth_header, "Bearer ", "")

    with {:ok, user_id} <- Echo.Auth.JWT.extract_user_id(token),
         {:ok, upload, conn} <- parse_multipart(conn),
         {:ok, file_url} <- Echo.Media.upload_chat_file(user_id, upload) do
      send_resp(
        conn,
        200,
        Jason.encode!(%{
          url: file_url,
          mime: upload.content_type
        })
      )
    else
      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Upload failed"}))
    end
  end

  defp route(conn, "GET", "/api/chats/" <> rest) do
    case String.split(rest, "/") do
      [chat_id, "search"] ->
        handle_chat_search(conn, chat_id)

      _ ->
        not_found(conn)
    end
  end

  ## -------- SPA fallback (Vue Router support) --------

  defp route(conn, "GET", _path) do
    send_file(conn, 200, "priv/static/index.html")
  end

  ## -------- Final fallback --------

  defp route(conn, _method, _path) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, ~s({"error":"Not found"}))
  end

  defp parse_multipart(conn) do
    opts =
      Plug.Parsers.init(
        parsers: [:multipart],
        pass: ["image/*", "application/*"],
        length: 20_000_000
      )

    conn = Plug.Parsers.call(conn, opts)

    cond do
      upload = conn.params["avatar"] ->
        case upload do
          %Plug.Upload{content_type: ct}
          when ct in ["image/png", "image/jpeg", "image/webp"] ->
            {:ok, upload, conn}

          _ ->
            {:error, :invalid_avatar}
        end

      upload = conn.params["file"] ->
        case upload do
          %Plug.Upload{} ->
            {:ok, upload, conn}

          _ ->
            {:error, :invalid_file}
        end

      true ->
        {:error, :no_file}
    end
  end

  defp handle_chat_search(conn, chat_id) do
    conn = Plug.Conn.fetch_query_params(conn)
    query = conn.params["q"]

    cond do
      is_nil(query) or query == "" ->
        send_resp(
          conn,
          400,
          Jason.encode!(%{error: "Missing search query"})
        )

      true ->
        results = Echo.Chats.Chat.search_messages(chat_id, query)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(results))
    end
  end

  defp handle_group_avatar_upload(conn, group_id) do
    auth_header = List.first(get_req_header(conn, "authorization")) || ""
    token = String.replace(auth_header, "Bearer ", "")

    with {:ok, _user_id} <- Echo.Auth.JWT.extract_user_id(token),
        {:ok, upload, conn} <- parse_multipart(conn),
        {:ok, url} <- Echo.Media.upload_group_avatar(group_id, upload) do
      send_resp(conn, 200, Jason.encode!(%{avatar_url: url}))
    else
      error ->
        IO.inspect(error, label: "GROUP AVATAR UPLOAD ERROR")
        send_resp(conn, 400, Jason.encode!(%{error: "Avatar upload failed"}))
    end
end

  defp not_found(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{error: "Not found"}))
  end
end
