defmodule JumpaWeb.LevelChannelTest do
  use JumpaWeb.ChannelCase

  import JumpaApi.GameFixtures

  @player_token "abc"

  setup do
    player = create_player()

    %{player: player}
  end

  test "send to level channel", %{player: player} do
    {:ok, _, socket} =
      JumpaWeb.GameSocket
      |> socket()
      |> subscribe_and_join(JumpaWeb.LevelChannel, "level:123", %{"player_token" => @player_token})

    data = %{"player_token" => @player_token, pos_x: 10.5, pos_y: 20.42}
    push(socket, "walk_absolute", data)

    res = %{player_id: player.id, pos_x: 10.5, pos_y: 20.42}
    assert_broadcast "walk_absolute", ^res
    assert true
  end

  defp create_player() do
    room_attr = %{token: @player_token}
    room = room_fixture(room_attr)

    player_attr = %{
      room_id: room.id,
      token: "abc"
    }

    player_fixture(player_attr)
  end
end
