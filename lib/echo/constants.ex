defmodule Echo.Constants do
  @online "Online"
  @offline "Offline"
  @outgoing "outgoing"
  @incoming "incoming"
  @private "private"
  @group "group"

  def online, do: @online
  def offline, do: @offline

  def outgoing, do: @outgoing
  def incoming, do: @incoming

  def private_chat(), do: @private
  def group_chat(), do: @group

  def messages_page_size, do: 50
end
