defmodule GenGameWeb.RequestHandlers.SessionHandler do
  import GenGame.ServerAuthoritative

  alias GenGame.PlayerSession

  def create_session(%{"username" => username}, socket) do
    dispatch_event(:before_create_session, %{username: username, socket: socket})
    token = PlayerSession.create(username)
    dispatch_event(:after_create_session, %{token: token, socket: socket})

    {:reply, {:ok, %{token: token}}, socket}
  end

  def ping(_, socket) do
    {:reply, {:ok, "pong"}, socket}
  end
end
