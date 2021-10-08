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
end
