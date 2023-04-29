defmodule JumpaWeb.GameView do
  use JumpaWeb, :view
  alias JumpaWeb.GameView

  def render("show.json", %{room: room}) do
    %{
      data: %{
        room: get_room(room)
      }
    }
  end

  defp get_room(game) do
    %{
      id: game.id,
      token: game.token
    }
  end
end
