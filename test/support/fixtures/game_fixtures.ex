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
        code: "some code",
        region: "some region"
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
        nick: "some nick",
        room_id: "some room_id"
      })
      |> Jumpa.Game.create_player()

    player
  end
end
