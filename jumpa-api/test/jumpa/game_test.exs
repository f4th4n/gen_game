defmodule Jumpa.GameTest do
  use Jumpa.DataCase

  alias Jumpa.Game

  describe "rooms" do
    alias Jumpa.Game.Room

    import Jumpa.GameFixtures

    @invalid_attrs %{code: nil, region: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Game.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Game.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{token: "some token", region: "some region"}

      assert {:ok, %Room{} = room} = Game.create_room(valid_attrs)
      assert room.token == "some token"
      assert room.region == "some region"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{token: "some updated token", region: "some updated region"}

      assert {:ok, %Room{} = room} = Game.update_room(room, update_attrs)
      assert room.token == "some updated token"
      assert room.region == "some updated region"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_room(room, @invalid_attrs)
      assert room == Game.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Game.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Game.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Game.change_room(room, %{})
    end
  end

  describe "players" do
    alias Jumpa.Game.Player

    import Jumpa.GameFixtures

    @invalid_attrs %{nick: nil, room_id: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Game.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Game.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = %{
        nick: "some nick",
        room_id: 1,
        token: "token",
        pos_x: 0.0,
        pos_y: 0.0
      }

      assert {:ok, %Player{} = player} = Game.create_player(valid_attrs)
      assert player.nick == "some nick"
      assert player.room_id == 1
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{nick: "some updated nick", room_id: 99}

      assert {:ok, %Player{} = player} = Game.update_player(player, update_attrs)
      assert player.nick == "some updated nick"
      assert player.room_id == 99
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_player(player, @invalid_attrs)
      assert player == Game.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Game.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Game.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Game.change_player(player, %{})
    end
  end
end
