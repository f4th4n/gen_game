defmodule Benchmark.BenchmarkChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.Presence

  @impl true
  def join("benchmark:ccu", %{"device_id" => device_id}, socket) do
    {:ok, assign(socket, :device_id, device_id)}
  end

  def join("benchmark:new_user", %{"device_id" => _device_id}, socket) do
    # TODO implement this
    {:ok, socket}
  end

  def join("benchmark:gameplay", %{"device_id" => _device_id}, socket) do
    # TODO implement this
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, a} =
      Presence.track(socket, socket.assigns.name, %{
        online_at: inspect(System.system_time(:second))
      })

    IO.inspect({"masuk after join", socket.assigns.name, a})

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
