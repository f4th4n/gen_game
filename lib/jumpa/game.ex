defmodule Jumpa.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Jumpa.Game.Players
  alias Jumpa.Game.Rooms

  def list_rooms(), do: Rooms.list_rooms()
  def get_room!(id), do: Rooms.get_room!(id)
  def create_room(attrs), do: Rooms.create_room(attrs)
  def update_room(room, attrs), do: Rooms.update_room(room, attrs)
  def delete_room(room), do: Rooms.delete_room(room)
  def change_room(room, attrs), do: Rooms.change_room(room, attrs)

  def list_players(), do: Players.list_players()
  def list_players_by_room(room_id), do: Players.list_players_by_room(room_id)
  def get_player_by(opts), do: Players.get_by(opts)
  def get_player_by_token(token), do: Players.get_player_by_token(token)
  def get_player!(id), do: Players.get_player!(id)
  def get_players_in_the_same_room(player_token), do: Players.get_players_in_the_same_room(player_token)
  def create_player(attrs), do: Players.create_player(attrs)
  def update_player(player, attrs), do: Players.update_player(player, attrs)
  def delete_player(player), do: Players.delete_player(player)
  def change_player(player, attrs), do: Players.change_player(player, attrs)
  def view_player(player), do: Players.view_player(player)

  def get_player_by_id_and_room_token(player_id, room_token),
    do: Players.get_player_by_id_and_room_token(player_id, room_token)

  def walk_absolute(player_token, x, y) do
    Players.walk_absolute(player_token, x, y)
  end
end
