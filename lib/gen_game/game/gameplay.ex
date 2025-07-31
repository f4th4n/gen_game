defmodule GenGame.Game.Gameplay do
  @moduledoc """
  Core module to manage a game state.

  Example create game, and then try to relay:
  iex > GenGame.Game.Gameplay.create_match("p1", "game_100")
  iex > :ok = GenGame.Game.Gameplay.relay("game_100", %{"enemy_1": %{hp: 100}})
  iex > GenGame.Game.Gameplay.get(match_id)
  """
  @table :gameplay

  use GenGame.Storage, table: @table

  alias GenGame.Game.Gameplay
  alias GenGame.Game.Game

  @spec create_example_match() :: :ok
  def create_example_match() do
    create_match("username", "example")
  end

  @spec create_match(binary(), binary()) :: :ok
  def create_match(owner_username, match_id) do
    # TODO add match query
    Gameplay.set(match_id, %Game{
      status: :started,
      players: [owner_username],
      created_at: :os.system_time(:millisecond)
    })
  end

  @spec check(binary()) :: :exist | :not_found
  def check(match_id) when is_binary(match_id) do
    case Gameplay.get(match_id) do
      nil -> :not_found
      %Game{} -> :exist
    end
  end

  @spec get_last_match_id() :: term()
  def get_last_match_id() do
    case Gameplay.lists() do
      [] ->
        nil

      entries ->
        entries
        |> Enum.max_by(fn {_, value} -> value.created_at end)
        # Extract the key-value pair
        |> elem(0)
    end
  end

  @doc """
  set_authoritative/3 can only be called by server.
  """
  @spec set_authoritative(binary(), binary(), term()) :: :ok | {:error, :not_found}
  def set_authoritative(match_id, key, value) do
    case Gameplay.get(match_id) do
      %Game{private_state: private_state} = game ->
        new_private_state = Map.put(private_state, key, value)
        Gameplay.set(match_id, Map.put(game, :private_state, new_private_state))

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  relay/3 can be called by clients that associated with this game.
  """
  @spec relay(binary(), map()) :: :ok | {:error, :not_found}
  def relay(match_id, payload) do
    # TODO prevent client from changing the state of unstarted game
    case Gameplay.get(match_id) do
      %Game{public_state: public_state} = game ->
        Task.async(fn ->
          Gameplay.set(match_id, Map.put(game, :public_state, Map.merge(public_state, payload)))
        end)

        :ok

      nil ->
        {:error, :not_found}
    end
  end
end
