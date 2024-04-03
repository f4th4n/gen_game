defmodule GenGameWeb.AuthChannel do
  @moduledoc """
  This channel is used for authenticating player. Currently there is only authenticating via device ID.
  """

  use GenGameWeb, :channel

  @impl true
  def join("auth", _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("create_session", %{"username" => username}, socket) do
    # upsert session
    token = GenGame.PlayerSession.generate_token(username)

    {:reply, {:ok, %{token: token}}, socket}
  end
end
