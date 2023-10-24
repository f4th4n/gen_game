defmodule GenGameWeb.PlayerViewTest do
  use GenGameWeb.ConnCase, async: true

  import Phoenix.View

  alias GenGameApi.GameFixtures
  alias GenGameApi.Game.Players
  alias GenGameApi.Repo

  describe "render/2" do
    test "render show.json with param player" do
      player = GameFixtures.player_fixture()
      player_id = player.id
      assert %{data: %{id: ^player_id}} = render(GenGameWeb.PlayerView, "show.json", %{player: player})
    end

    test "render show.json with param player with room" do
      room = GameFixtures.room_fixture()
      player = GameFixtures.player_fixture(room_id: room.id)

      player =
        Players.get_player!(player.id)
        |> Repo.preload(:room)

      player_id = player.id
      room_token = room.token

      assert %{
               data: %{
                 id: ^player_id,
                 room: %{token: ^room_token}
               }
             } = render(GenGameWeb.PlayerView, "show.json", %{player: player})
    end
  end
end
