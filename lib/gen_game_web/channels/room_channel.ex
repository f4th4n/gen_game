defmodule GenGameWeb.RoomChannel do
  use GenGameWeb, :channel

  @impl true
  def join("room:lobby", %{"name" => name}, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :name, name)}
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
