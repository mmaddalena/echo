defmodule Echo.Media do
  alias Echo.Users.User
  alias Echo.Chats.Chat

  @bucket "echo-fiuba"
  @scope "https://www.googleapis.com/auth/devstorage.full_control"

  # Use a path relative to the application root
  @local_storage_path Application.app_dir(:echo, "priv/uploads")

  # Check if GCP is configured by verifying the service account file exists
  defp gcp_configured? do
    File.exists?("priv/gcp/service-account.json")
  end

  # Ensure the base upload directory exists
  defp ensure_base_directories! do
    # Create the main uploads directory and all subdirectories
    base_dirs = [
      @local_storage_path,
      Path.join(@local_storage_path, "avatars"),
      Path.join(@local_storage_path, "avatars/users"),
      Path.join(@local_storage_path, "avatars/groups"),
      Path.join(@local_storage_path, "avatars/register"),
      Path.join(@local_storage_path, "chat")
    ]

    Enum.each(base_dirs, &File.mkdir_p!/1)
  end

  def upload_user_avatar(user_id, %Plug.Upload{} = upload) do
    if gcp_configured?() do
      # Upload to GCS
      with {:ok, url} <- upload_avatar_gcp(user_id, upload),
           {:ok, user} <- User.update_avatar(user_id, url) do
        {:ok, user}
      end
    else
      # Store locally
      with {:ok, url} <- upload_avatar_local(user_id, upload),
           {:ok, user} <- User.update_avatar(user_id, url) do
        {:ok, user}
      end
    end
  end

  # GCP upload functions
  defp upload_avatar_gcp(user_id, %Plug.Upload{} = upload) do
    ext = Path.extname(upload.filename)

    object_name =
      "avatars/users/#{user_id}-#{Ecto.UUID.generate()}#{ext}"

    with {:ok, _object} <- upload_to_gcs(object_name, upload) do
      {:ok, public_url(object_name)}
    end
  rescue
    e ->
      IO.inspect(e, label: "Avatar upload error")
      {:error, :upload_failed}
  end

  def upload_to_gcs(object_name, upload) do
    {:ok, %{token: token}} = Goth.fetch(Echo.Goth, @scope)

    conn = GoogleApi.Storage.V1.Connection.new(token)
    {:ok, object} =
      GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_simple(
        conn,
        @bucket,
        "multipart",
        %GoogleApi.Storage.V1.Model.Object{
          name: object_name,
          contentType: upload.content_type
        },
        upload.path
      )

    {:ok, object}
  rescue
    e ->
      IO.inspect(e, label: "upload error")
      {:error, :upload_failed}
  end

  # Local storage functions
  defp upload_avatar_local(user_id, %Plug.Upload{} = upload) do
    # Ensure base directories exist before writing
    ensure_base_directories!()

    ext = Path.extname(upload.filename)

    # Create unique filename
    filename = "#{user_id}-#{Ecto.UUID.generate()}#{ext}"

    # Create user-specific directory
    user_dir = Path.join([@local_storage_path, "avatars", "users", to_string(user_id)])
    File.mkdir_p!(user_dir)

    # Destination path
    dest_path = Path.join(user_dir, filename)

    # Copy file
    case File.cp(upload.path, dest_path) do
      :ok ->
        {:ok, local_url("/uploads/avatars/users/#{user_id}/#{filename}")}
      {:error, reason} ->
        IO.inspect(reason, label: "Local avatar upload error")
        {:error, :upload_failed}
    end
  end

  def upload_chat_file(user_id, %Plug.Upload{} = upload) do
    if gcp_configured?() do
      upload_chat_file_gcp(user_id, upload)
    else
      upload_chat_file_local(user_id, upload)
    end
  end

  defp upload_chat_file_gcp(user_id, %Plug.Upload{} = upload) do
    ext = Path.extname(upload.filename)

    object_name =
      "chat/#{user_id}/#{Ecto.UUID.generate()}#{ext}"

    with {:ok, object} <- upload_to_gcs(object_name, upload) do
      url = "https://storage.googleapis.com/#{@bucket}/#{object.name}"
      {:ok, url}
    end
  end

  defp upload_chat_file_local(user_id, %Plug.Upload{} = upload) do
    # Ensure base directories exist before writing
    ensure_base_directories!()

    ext = Path.extname(upload.filename)

    filename = "#{Ecto.UUID.generate()}#{ext}"

    # Create user-specific chat directory
    user_chat_dir = Path.join([@local_storage_path, "chat", to_string(user_id)])
    File.mkdir_p!(user_chat_dir)

    dest_path = Path.join(user_chat_dir, filename)

    case File.cp(upload.path, dest_path) do
      :ok ->
        url = local_url("/uploads/chat/#{user_id}/#{filename}")
        {:ok, url}
      {:error, reason} ->
        IO.inspect(reason, label: "Local chat upload error")
        {:error, :upload_failed}
    end
  end

  def upload_register_avatar(%Plug.Upload{} = upload) do
    if gcp_configured?() do
      upload_register_avatar_gcp(upload)
    else
      upload_register_avatar_local(upload)
    end
  end

  defp upload_register_avatar_gcp(%Plug.Upload{} = upload) do
    ext = Path.extname(upload.filename)

    object_name =
      "avatars/register/#{Ecto.UUID.generate()}#{ext}"

    with {:ok, object} <- upload_to_gcs(object_name, upload) do
      url = "https://storage.googleapis.com/#{@bucket}/#{object.name}"
      {:ok, url}
    end
  end

  defp upload_register_avatar_local(%Plug.Upload{} = upload) do
    # Ensure base directories exist before writing
    ensure_base_directories!()

    ext = Path.extname(upload.filename)

    filename = "#{Ecto.UUID.generate()}#{ext}"

    register_dir = Path.join([@local_storage_path, "avatars", "register"])
    File.mkdir_p!(register_dir)

    dest_path = Path.join(register_dir, filename)

    case File.cp(upload.path, dest_path) do
      :ok ->
        url = local_url("/uploads/avatars/register/#{filename}")
        {:ok, url}
      {:error, reason} ->
        IO.inspect(reason, label: "Local register avatar upload error")
        {:error, :upload_failed}
    end
  end

  def upload_group_avatar(group_id, %Plug.Upload{} = upload) do
    if gcp_configured?() do
      upload_group_avatar_gcp(group_id, upload)
    else
      upload_group_avatar_local(group_id, upload)
    end
  end

  defp upload_group_avatar_gcp(group_id, %Plug.Upload{} = upload) do
    ext = Path.extname(upload.filename)

    object_name =
      "avatars/groups/#{group_id}-#{Ecto.UUID.generate()}#{ext}"

    with {:ok, object} <- upload_to_gcs(object_name, upload) do
        Chat.update_group_avatar(group_id, public_url(object.name))
        {:ok, public_url(object.name)}
    end
  rescue
    e ->
      IO.inspect(e, label: "Group avatar upload error")
      {:error, :upload_failed}
  end

  defp upload_group_avatar_local(group_id, %Plug.Upload{} = upload) do
    # Ensure base directories exist before writing
    ensure_base_directories!()

    ext = Path.extname(upload.filename)

    filename = "#{group_id}-#{Ecto.UUID.generate()}#{ext}"

    groups_dir = Path.join([@local_storage_path, "avatars", "groups"])
    File.mkdir_p!(groups_dir)

    dest_path = Path.join(groups_dir, filename)

    case File.cp(upload.path, dest_path) do
      :ok ->
        url = local_url("/uploads/avatars/groups/#{filename}")
        Chat.update_group_avatar(group_id, url)
        {:ok, url}
      {:error, reason} ->
        IO.inspect(reason, label: "Local group avatar upload error")
        {:error, :upload_failed}
    end
  end

  # Helper functions
  defp public_url(object_name) do
    "https://storage.googleapis.com/#{@bucket}/#{object_name}"
  end

  defp local_url(path) do
    # You might want to make the base URL configurable
    base_url = Application.get_env(:echo, :base_url, "http://localhost:4000")
    "#{base_url}#{path}"
  end
end
