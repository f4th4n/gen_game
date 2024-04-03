defmodule GenGameWeb.Channels.GameplayChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.Presence
  alias GenGame.PlayerSession

  @impl true
  def join("game:" <> game_id, %{"token" => token}, socket) do
    case PlayerSession.verify(token) do
      {:ok, username} ->
        send(self(), :after_join)

        {:ok, assign(socket, game_id: game_id, username: username)}

      {:error, _error} ->
        {:error, %{msg: "invalid_token"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
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
