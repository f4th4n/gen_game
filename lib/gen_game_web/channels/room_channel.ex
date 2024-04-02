defmodule GenGameWeb.RoomChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.Presence

  @impl true
  def join("room:lobby", %{"device_id" => device_id}, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :device_id, device_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.device_id, %{
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
