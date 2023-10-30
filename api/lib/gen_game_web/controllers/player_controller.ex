defmodule GenGameWeb.PlayerController do
  use GenGameWeb, :controller

  alias GenGameApi.Game

  action_fallback GenGameWeb.FallbackController

  def auth(conn, %{"player_token" => player_token, "room_token" => room_token}) do
    with player = %{} <- Game.get_player_by_token(token: player_token, room_token: room_token) do
      render(conn, "show.json", player: player)
    end
  end
end
