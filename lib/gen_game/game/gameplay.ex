defmodule GenGame.Game.Gameplay do
  @moduledoc """
  Core module to manage a game state.

  Example create game, and then try to relay:
  iex > game_id = GenGame.Game.Gameplay.create_game()
  iex > :ok = GenGame.Game.Gameplay.relay(game_id, "enemy_1", %{hp: 100})
  iex > GenGame.Game.Gameplay.get(game_id)
  """
  @table :gameplay

  use GenGame.Storage, table: @table

  alias GenGame.Game.Gameplay
  alias GenGame.Game.Game

  @spec create_game() :: binary()
  def create_game() do
    game_id = Ecto.UUID.generate()
    Gameplay.set(game_id, %Game{status: :started})

    game_id
  end

  @spec check(binary()) :: :exist | :not_found
  def check(game_id) when is_binary(game_id) do
    case Gameplay.get(game_id) do
      nil -> :not_found
      %Game{} -> :exist
    end
  end

  @doc """
  set_authoritative/3 can only be called by server.
  """
  @spec set_authoritative(binary(), binary(), term()) :: :ok | {:error, :not_found}
  def set_authoritative(game_id, key, value) do
    case Gameplay.get(game_id) do
      %Game{private_state: private_state} = game ->
        new_private_state = Map.put(private_state, key, value)
        Gameplay.set(game_id, Map.put(game, :private_state, new_private_state))

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  relay/3 can be called by clients that associated with this game.
  """
  @spec relay(binary(), binary(), term()) :: :ok | {:error, :not_found}
  def relay(game_id, key, value) do
    # TODO prevent client from changing the state of unstarted game
    case Gameplay.get(game_id) do
      %Game{public_state: public_state} = game ->
        new_public_state = Map.put(public_state, key, value)
        Gameplay.set(game_id, Map.put(game, :public_state, new_public_state))

      nil ->
        {:error, :not_found}
    end
  end
end
