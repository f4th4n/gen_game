defmodule GenGameWeb.GameController do
  use GenGameWeb, :controller

  alias GenGameApi.Game

  action_fallback GenGameWeb.FallbackController

  def new(conn, %{"player_token" => player_token}) do
    case GenGameApi.Game.new_game() do
      {:ok, room} -> render(conn, "show.json", room: room)
      _ -> :error
    end
  end

  def new(_conn, _params) do
    :error
  end
end
