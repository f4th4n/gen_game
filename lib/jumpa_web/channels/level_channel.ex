defmodule JumpaWeb.LevelChannel do
  use Phoenix.Channel
  alias JumpaWeb.Presence
  alias Jumpa.Repo
  alias Jumpa.Game.Player

  require Logger

  intercept ["request_ping"]

  def join(_topic, %{"player_id" => player_id, "room_id" => room_id}, socket) do
    # TODO change player_id with token
    player = Repo.get(Player, player_id)
    join_if_player_valid(player, room_id, socket)
  end

  def join(_topic, _params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  def join_if_player_valid(nil, _room_id, _socket), do: {:error, %{msg: "Player not found"}}

  def join_if_player_valid(player, room_id, socket) do
    send(self(), :after_join)
    {:ok, %{channel: "room:#{room_id}"}, assign(socket, :player_id, player.id)}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    player = Repo.get(Player, socket.assigns.player_id)

    {:ok, _} =
      Presence.track(socket, "player:#{player.id}", %{
        player_id: player.id,
        nick: player.nick
      })

    {:noreply, socket}
  end

  def handle_in("walk", payload, socket) do
    broadcast(socket, "walk", payload)
    # {:reply, {:ok, %{ping: "walk to the fire"}}, socket}
    {:noreply, socket}
  end

  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
