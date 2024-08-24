defmodule GenGameWeb.RequestHandlers.SessionHandler do
  import GenGame.ServerAuthoritative

  require Logger

  alias GenGame.PlayerSession

  def create_session(%{"username" => username}, socket) do
    dispatch_event(:before_create_session, %{username: username, socket: socket})
    token = PlayerSession.create(username)
    dispatch_event(:after_create_session, %{token: token, socket: socket})
    Logger.info("[SessionHandler] create session '#{username}'")

    {:reply, {:ok, %{token: token}}, socket}
  end

  def ping(_, socket) do
    Logger.info("[SessionHandler] ping")
    {:reply, {:ok, "pong"}, socket}
  end
end
