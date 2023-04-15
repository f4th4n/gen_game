defmodule Jumpa.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jumpa.Game` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        token: "abc",
        region: "sea-1"
      })
      |> Jumpa.Game.create_room()

    room
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        nick: "ali",
        token: "abc",
        pos_x: 0.0,
        pos_y: 0.0,
        room_id: 1
      })
      |> Jumpa.Game.create_player()

    player
  end
end
