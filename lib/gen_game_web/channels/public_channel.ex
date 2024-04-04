defmodule GenGameWeb.Channels.PublicChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.RequestHandlers.SessionHandler

  @impl true
  def join("public", _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("create_session", params, socket),
    do: SessionHandler.create_session(params, socket)
end
