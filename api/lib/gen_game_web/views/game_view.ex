defmodule GenGameWeb.GameView do
  use GenGameWeb, :view
  alias GenGameWeb.GameView

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
