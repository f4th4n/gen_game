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

  defp get_room(room) do
    %{
      id: room.id,
      token: room.token,
      status: room.status
    }
  end
end
