
defmodule Echo.Messages.Messages do
  alias Echo.Repo

  def create_message(attrs) do
    %Echo.Schemas.Message{}
    |> Echo.Schemas.Message.changeset(attrs)
    |> Repo.insert()
  end



end
