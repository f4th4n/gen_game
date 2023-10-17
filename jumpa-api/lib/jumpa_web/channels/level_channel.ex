defmodule JumpaWeb.LevelChannel do
  use Phoenix.Channel
  alias JumpaWeb.Presence
  alias Jumpa.Repo
  alias JumpaApi.Game.Player
  alias JumpaApi.Game

  require Logger

  intercept ["request_ping"]

  def join("level:" <> _room_token, %{"player_token" => player_token}, socket) do
    player = Game.get_player_by_token(player_token)
    join_if_player_valid(player, socket)
  end

  def join(_topic, _params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  def join_if_player_valid(nil, _socket), do: {:error, %{msg: "Player not found"}}

  def join_if_player_valid(player, socket) do
    send(self(), :after_join)
    {:ok, %{channel: "room:#{player.room.token}"}, assign(socket, :player_id, player.id)}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    player = JumpaApi.Game.get_player(socket.assigns.player_id)

    {:ok, _} =
      Presence.track(socket, "player:#{player.id}", %{
        player_id: player.id,
        nick: player.nick
      })

    {:noreply, socket}
  end

  # -------------------------------------------------------------------------------- event from client start here

  # TODO add validation by socket.assigns, see game_channel
  def handle_in("walk_absolute", %{"player_token" => player_token, "pos_x" => pos_x, "pos_y" => pos_y}, socket) do
    data = Game.walk_absolute(player_token, pos_x, pos_y)
    broadcast(socket, "walk_absolute", data)

    {:noreply, socket}
  end

  # TODO implement walk_relative
  def handle_in("walk_relative", _payload, socket) do
    data = nil
    broadcast(socket, "walk_absolute", data)
    {:noreply, socket}
  end

  def handle_in(
        "get_player_detail",
        %{"player_id" => player_id, "room_token" => room_token},
        socket
      ) do
    data =
      Game.get_player_by(token: room_token, id: player_id)
      |> Game.view_player()

    # TODO make it non blocking
    case data do
      %{player_id: _} ->
        broadcast(socket, "player_detail", data)

      _e ->
        :noop
    end

    {:noreply, socket}
  end

  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  # -------------------------------------------------------------------------------- event from server start here
  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
