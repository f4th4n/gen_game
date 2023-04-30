defmodule JumpaWeb.GameChannel do
  use Phoenix.Channel
  alias JumpaWeb.Presence
  alias Jumpa.Repo
  alias JumpaApi.Game.Player
  alias JumpaApi.Game

  require Logger

  intercept(["request_ping"])

  def join("game", %{"player_token" => player_token}, socket) do
    case Game.get_player_by_token(player_token) do
      %{id: player_id, room: %{token: room_token}} ->
        {:ok, socket}

      _ ->
        {:error, %{msg: "Player not found"}}
    end
  end

  def join(_topic, params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  # -------------------------------------------------------------------------------- event from client start here

  def handle_in("walk_relative", _payload, socket) do
    data = nil
    broadcast(socket, "walk_absolute", data)
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
