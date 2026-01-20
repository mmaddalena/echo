defmodule Echo.Media do
  alias GoogleApi.Storage.V1.Api.Objects
  alias Echo.Users.User
  alias Plug.Upload

  @bucket "echo-fiuba"
  @scope "https://www.googleapis.com/auth/devstorage.full_control"

  def upload_user_avatar(user_id, %Plug.Upload{} = upload) do
    # upload to gcs
    with {:ok, url} <- upload_to_gcs(user_id, upload),
         # update avatar_url in db
         {:ok, user} <- User.update_avatar(user_id, url) do
      {:ok, user}
    end
  end

  def upload_to_gcs(user_id, upload) do
    ext = Path.extname(upload.filename)
    object_name = "avatars/users/#{user_id}-#{Ecto.UUID.generate()}#{ext}"

    # Fetch token from Goth (GenServer)
    {:ok, %{token: token}} = Goth.fetch(Echo.Goth, @scope)

    # Build Google API connection
    conn = GoogleApi.Storage.V1.Connection.new(token)

    {:ok, _object} =
      Objects.storage_objects_insert_simple(
        conn,
        @bucket,
        "multipart",
        %GoogleApi.Storage.V1.Model.Object{
          name: object_name,
          contentType: upload.content_type
        },
        upload.path
      )

    {:ok, public_url(object_name)}
  rescue
    e ->
      IO.inspect(e, label: "Avatar upload error")
      {:error, :upload_failed}
  end

  defp public_url(object_name) do
    "https://storage.googleapis.com/#{@bucket}/#{object_name}"
  end

  # def upload_local_to_gcp(local_path, %Upload{} = original_upload) do
  #   fake_upload = %Upload{
  #     original_upload
  #     | path: local_path
  #   }

  #   # we use a temporary UUID instead of user_id
  #   temp_id = Ecto.UUID.generate()

  #   case Echo.Media.upload_user_avatar(temp_id, fake_upload) do
  #     {:ok, %{avatar_url: url}} ->
  #       {:ok, url}

  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end
end
