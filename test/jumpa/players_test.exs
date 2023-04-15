defmodule Jumpa.PlayerTest do
  use Jumpa.DataCase

  alias Jumpa.GameFixtures
  alias Jumpa.Game.Players

  describe "get_by/1" do
    test "with empty list opts returns all rooms" do
      player = GameFixtures.player_fixture(%{token: "abc"})

      assert [player] == Players.get_by([])
    end

    test "with token params returns rooms" do
      assert [] == Players.get_by(token: "abc")

      player = GameFixtures.player_fixture(%{token: "abc"})

      assert [player] == Players.get_by(token: "abc")
    end

    test "with token and room_token params returns rooms" do
      room = GameFixtures.room_fixture()
      player = GameFixtures.player_fixture(%{token: "abc", room_id: room.id})

      assert [] == Players.get_by(token: "abc", room_token: "wrong")
      assert [player] == Players.get_by(token: "abc", room_token: room.token)
    end
  end
end
