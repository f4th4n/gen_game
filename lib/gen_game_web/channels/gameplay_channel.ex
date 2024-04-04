defmodule GenGameWeb.Channels.GameplayChannel do
  use GenGameWeb, :channel

  alias GenGameWeb.Presence
  alias GenGameWeb.RequestHandlers.GameHandler

  @impl true
  def join("game:" <> match_id, %{"token" => token}, socket) do
    GameHandler.join(match_id, token, socket)
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

  def handle_info(_payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_in("ping", params, socket),
    do: GameHandler.ping(params, socket)

  def handle_in("set_state", params, socket),
    do: GameHandler.set_state(params, socket)

  def handle_in("get_state", params, socket),
    do: GameHandler.get_state(params, socket)

  def handle_in("rpc", params, socket),
    do: GameHandler.rpc(params, socket)
end
