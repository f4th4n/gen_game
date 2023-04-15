defmodule Jumpa.Game.Players do
  import Ecto.Query, warn: false
  alias Jumpa.Repo
  alias Jumpa.Game.Player
  alias Jumpa.Game.Room

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  def get_room_id_by_player(%Jumpa.Game.Player{} = player) do
    player.room_id
  end

  def get_room_id_by_player(_), do: nil

  def list_players_by_room(nil), do: nil

  def list_players_by_room(room_id) do
    query =
      from p in Player,
        where: p.room_id == ^room_id

    Repo.all(query)
  end

  @spec get_by(list()) :: list()
  def get_by(opts) when is_list(opts) do
    token = Keyword.get(opts, :token)
    room_token = Keyword.get(opts, :room_token)

    # TODO join rom only if necessary
    query =
      from p in Player,
        left_join: r in Room,
        on:
          r.id ==
            p.room_id

    query
    |> filter_by_token(token)
    |> filter_by_room_token(room_token)
    |> Repo.one()
    |> Repo.preload(:room)
  end

  def get_player_by_token(nil), do: nil

  def get_player_by_token(token) do
    Repo.get_by(Player, token: token)
    |> Repo.preload(:room)
  end

  def get_player!(id), do: Repo.get!(Player, id)
  def get_player(id), do: Repo.get(Player, id)

  def get_players_in_the_same_room(player_token) do
    get_player_by_token(player_token)
    |> Players.get_room_id_by_player()
    |> list_players_by_room()
  end

  def get_player_by_id_and_room_token(player_id, room_token) do
    Player
    |> join(:left, [player], Room)
    |> where([p, r], p.id == ^player_id)
    |> where([p, r], r.token == ^room_token)
    |> Repo.one()
  end

  @spec walk_absolute(binary(), float(), float()) :: map()
  def walk_absolute(player_token, x, y) do
    player = get_player_by_token(player_token)

    update_player(player, %{pos_x: x, pos_y: y})

    %{
      player_id: player.id,
      pos_x: x,
      pos_y: y
    }
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  # TODO use some struct
  def view_player(%Player{
        id: id,
        nick: nick,
        pos_x: pos_x,
        pos_y: pos_y
      }) do
    %{
      player_id: id,
      nick: nick,
      pos_x: pos_x,
      pos_y: pos_y
    }
  end

  def view_player(_), do: nil

  defp filter_by_token(query, nil), do: query
  defp filter_by_token(query, token), do: where(query, [p], p.token == ^token)

  defp filter_by_room_token(query, nil), do: query
  defp filter_by_room_token(query, room_token), do: where(query, [p, r], r.token == ^room_token)
end
