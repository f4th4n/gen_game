defmodule JumpaWeb.PlayerController do
  use JumpaWeb, :controller

  alias JumpaApi.Game

  action_fallback JumpaWeb.FallbackController

  def auth(conn, %{"player_token" => player_token, "room_token" => room_token}) do
    with player = %{} <- Game.get_player_by(token: player_token, room_token: room_token) do
      render(conn, "show.json", player: player)
    end
  end
end
