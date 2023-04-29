defmodule JumpaWeb.GameController do
  use JumpaWeb, :controller

  alias JumpaApi.Game

  action_fallback JumpaWeb.FallbackController

  def new(conn, %{"player_token" => player_token}) do
    case JumpaApi.Game.new_game() do
      {:ok, room} -> render(conn, "show.json", room: room)
      _ -> :error
    end
  end

  def new(_conn, _params) do
    :error
  end
end
