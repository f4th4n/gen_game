defmodule GenGameApp.Game.Rooms do
  import Ecto.Query, warn: false
  alias GenGameApp.Repo
  alias GenGameApp.Game.Room
  alias GenGameApp.Util

  @regions ["sea"]

  def find(opts) when is_list(opts) do
    token = Keyword.get(opts, :token)
    status = Keyword.get(opts, :status)

    Room
    |> filter_by_token(token)
    |> filter_by_status(status)
    |> Repo.all()
  end

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(), do: create_room(0)

  def create_room(attrs) when is_map(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @create_room_max_retry 5
  def create_room(@create_room_max_retry), do: {:error, "can't create room, max retries reached"}

  def create_room(retry) do
    random_region = Enum.random(@regions)
    # TODO implement multi region
    attrs = %{
      region: random_region,
      token: Util.random_string(10)
    }

    case create_room(attrs) do
      # same code, try again
      {:error, _} -> create_room(retry + 1)
      {:ok, room} -> {:ok, room}
    end
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @spec get_by(list()) :: list()
  def get_by(opts) when is_list(opts) do
    token = Keyword.get(opts, :token)

    Room
    |> filter_by_token(token)
    |> Repo.one()
  end

  defp filter_by_token(query, nil), do: query
  defp filter_by_token(query, token), do: where(query, [p], p.token == ^token)

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status), do: where(query, [p], p.status == ^status)
end
