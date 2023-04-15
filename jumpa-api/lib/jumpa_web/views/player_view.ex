defmodule JumpaWeb.PlayerView do
  use JumpaWeb, :view
  alias JumpaWeb.PlayerView

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: %{room: %{id: _}} = player}) do
    get_player(player)
    |> Map.put(:room, %{
      token: player.room.token,
      region: player.room.region
    })
  end

  def render("player.json", %{player: player}) do
    get_player(player)
  end

  defp get_player(player) do
    %{
      id: player.id,
      nick: player.nick,
      token: player.token,
      room_id: player.room_id,
      pos_x: player.pos_x,
      pos_y: player.pos_y
    }
  end
end
