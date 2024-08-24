defmodule GenGameWeb.Channels.PublicChannel do
  use GenGameWeb, :channel

  require Logger

  alias GenGameWeb.RequestHandlers.SessionHandler

  @impl true
  def join("public", params, socket) do
    Logger.info("[PublicChannel] join channel Public, params=#{inspect(params)}")
    {:ok, socket}
  end

  @impl true
  def handle_in("create_session", params, socket),
    do: SessionHandler.create_session(params, socket)

  @impl true
  def handle_in("ping", params, socket),
    do: SessionHandler.ping(params, socket)
end
