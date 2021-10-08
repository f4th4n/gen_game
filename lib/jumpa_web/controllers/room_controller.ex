defmodule JumpaWeb.RoomController do
  use JumpaWeb, :controller

  alias Jumpa.Game
  alias Jumpa.Game.Room

  action_fallback JumpaWeb.FallbackController

  def index(conn, _params) do
    rooms = Game.list_rooms()
    render(conn, "index.json", rooms: rooms)
  end

  def create(conn, %{"room" => room_params}) do
    with {:ok, %Room{} = room} <- Game.create_room(room_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.room_path(conn, :show, room))
      |> render("show.json", room: room)
    end
  end

  def show(conn, %{"id" => id}) do
    room = Game.get_room!(id)
    render(conn, "show.json", room: room)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Game.get_room!(id)

    with {:ok, %Room{} = room} <- Game.update_room(room, room_params) do
      render(conn, "show.json", room: room)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Game.get_room!(id)

    with {:ok, %Room{}} <- Game.delete_room(room) do
      send_resp(conn, :no_content, "")
    end
  end
end
