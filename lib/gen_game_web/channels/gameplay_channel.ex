defmodule GenGameWeb.Channels.GameplayChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.Presence
  alias GenGame.PlayerSession
  alias GenGame.Gameplay

  @impl true
  def join("game:" <> game_id, %{"token" => token}, socket) do
    with :exist <- Gameplay.check(game_id),
         {:ok, username} <- PlayerSession.verify(token) do
      send(self(), :update_presence)
      {:ok, assign(socket, game_id: game_id, username: username)}
    else
      {:error, _error} ->
        {:error, %{msg: "invalid token"}}

      :not_found ->
        {:error, %{msg: "game not found"}}
    end
  end

  @impl true
  def handle_info(:update_presence, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.username, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
