defmodule JumpaWeb.PlayerController do
  use JumpaWeb, :controller

  alias Jumpa.Game
  alias Jumpa.Game.Player

  action_fallback JumpaWeb.FallbackController

  def auth(conn, %{"player_token" => player_token, "room_token" => room_token}) do
    player = Game.get_player_by(token: player_token, room_token: room_token)

    render(conn, "show.json", player: player)
    # TODO add room via Map.put_new
    # |> Map.put_new(:room, render(player, JumpaWeb.RoomView, "room.json", as: :room))
  end
end
