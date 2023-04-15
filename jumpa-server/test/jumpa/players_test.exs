defmodule Jumpa.PlayerTest do
  use Jumpa.DataCase

  alias Jumpa.GameFixtures
  alias Jumpa.Game.Players
  alias Jumpa.Game.Player

  describe "get_by/1" do
    test "with empty list opts returns all rooms" do
      assert nil == Players.get_by(token: "abc")

      %{id: id} = GameFixtures.player_fixture(%{token: "abc"})

      assert %Player{id: ^id, room: nil} = Players.get_by([])
    end

    test "with token params returns rooms" do
      assert nil == Players.get_by(token: "abc")

      %{id: id} = GameFixtures.player_fixture(%{token: "abc"})

      assert %Player{id: ^id, room: nil} = Players.get_by(token: "abc")
    end

    test "with token and room_token params returns rooms" do
      %{id: room_id, token: room_token} = GameFixtures.room_fixture()
      %{id: player_id} = GameFixtures.player_fixture(%{token: "abc", room_id: room_id})

      assert nil == Players.get_by(token: "abc", room_token: "wrong")

      assert %Player{
               id: ^player_id,
               room: %{id: ^room_id}
             } = Players.get_by(token: "abc", room_token: room_token)
    end
  end
end
