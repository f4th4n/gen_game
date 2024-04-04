defmodule GenGame.Game.Gameplay do
  @moduledoc """
  Core module to manage a game state.

  Example create game, and then try to relay:
  iex > match_id = GenGame.Game.Gameplay.create_game()
  iex > :ok = GenGame.Game.Gameplay.relay(match_id, "enemy_1", %{hp: 100})
  iex > GenGame.Game.Gameplay.get(match_id)
  """
  @table :gameplay

  use GenGame.Storage, table: @table

  alias GenGame.Game.Gameplay
  alias GenGame.Game.Game

  @spec create_game() :: binary()
  def create_game() do
    match_id = Ecto.UUID.generate()
    Gameplay.set(match_id, %Game{status: :started})

    match_id
  end

  @spec check(binary()) :: :exist | :not_found
  def check(match_id) when is_binary(match_id) do
    case Gameplay.get(match_id) do
      nil -> :not_found
      %Game{} -> :exist
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
  @spec relay(binary(), binary(), term()) :: :ok | {:error, :not_found}
  def relay(match_id, key, value) do
    # TODO prevent client from changing the state of unstarted game
    case Gameplay.get(match_id) do
      %Game{public_state: public_state} = game ->
        new_public_state = Map.put(public_state, key, value)
        Gameplay.set(match_id, Map.put(game, :public_state, new_public_state))

      nil ->
        {:error, :not_found}
    end
  end
end
