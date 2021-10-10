defmodule JumpaWeb.LevelChannel do
  use Phoenix.Channel
  alias JumpaWeb.Presence
  alias Jumpa.Repo
  alias Jumpa.Game.Player

  require Logger

  intercept ["request_ping"]

  def join(_topic, %{"player_id" => player_id}, socket) do
    # TODO change player_id with token
    player = Repo.get(Player, player_id)
    join_if_player_valid(player, socket)
  end

  def join(_topic, _params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  def join_if_player_valid(nil, _socket), do: {:error, %{msg: "Player not found"}}

  def join_if_player_valid(player, socket) do
    send(self(), :after_join)
    {:ok, %{channel: "room:#{player.room_id}"}, assign(socket, :player_id, player.id)}
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

  # -------------------------------------------------------------------------------- event from client start here

  def handle_in("get_positions", payload, socket) do
    players = Jumpa.Game.list_players_for_client()
    response = JumpaWeb.PlayerView.render("index.json", players: players)
    {:reply, {:ok, response}, socket}
  end

  # TODO implement walk_relative
  def handle_in("walk_absolute", payload, socket) do
    broadcast(socket, "walk_absolute", payload)
    {:noreply, socket}
  end

  # -------------------------------------------------------------------------------- event from server start here
  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
