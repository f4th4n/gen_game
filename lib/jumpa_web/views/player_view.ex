defmodule JumpaWeb.PlayerView do
  use JumpaWeb, :view
  alias JumpaWeb.PlayerView

  def render("index.json", %{players: players}) do
    %{data: render_many(players, PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{
      id: player.id,
      nick: player.nick,
      room_id: player.room_id
    }
  end
end
