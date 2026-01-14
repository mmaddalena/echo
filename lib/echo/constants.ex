defmodule Echo.Constants do
  @online "Online"
  @offline "Offline"
  @outgoing "outgoing"
  @incoming "incoming"

  def online, do: @online
  def offline, do: @offline

  def outgoing, do: @outgoing
  def incoming, do: @incoming

  def messages_page_size, do: 50
end
