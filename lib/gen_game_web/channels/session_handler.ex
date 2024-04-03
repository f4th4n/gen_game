defmodule GenGameWeb.Channels.SessionHandler do
  alias GenGame.PlayerSession

  def create_session(%{"username" => username}, socket) do
    token = PlayerSession.create(username)

    {:reply, {:ok, %{token: token}}, socket}
  end
end
