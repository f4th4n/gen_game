defmodule GenGame.Gameplay do
  @moduledoc """
  Core module to manage a game state.

  Example create game, and then try to relay:
  iex > game_id = GenGame.Gameplay.create_game()
  iex > :ok = GenGame.Gameplay.relay(game_id, "enemy_1", %{hp: 100})
  """
  @table :gameplay

  use GenGame.Storage, table: @table

  alias GenGame.Gameplay
  alias GenGame.Game.Game

  @spec create_game() :: binary()
  def create_game() do
    game_id = Ecto.UUID.generate()
    Gameplay.set(game_id, %Game{})

    game_id
  end

  @spec check(binary()) :: :exist | :not_found
  def check(game_id) when is_binary(game_id) do
    case Gameplay.get(game_id) do
      [] -> :not_found
      [_h | _t] -> :exist
    end
  end

  @spec relay(binary(), binary(), term()) :: :ok | {:error, :not_found}
  def relay(game_id, key, value) do
    case Gameplay.get(game_id) do
      %Game{state: state} = game ->
        new_state = Map.put(state, key, value)
        Gameplay.set(game_id, Map.put(game, :state, new_state))

      nil ->
        {:error, :not_found}
    end
  end
end
