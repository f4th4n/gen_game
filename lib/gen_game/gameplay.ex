defmodule GenGame.Gameplay do
  use GenServer

  alias Phoenix.PubSub

  @table :gameplay
  @pubsub GenGame.PubSub
  @topic "game"

  # ----------------------------------------------------------------------------------------------- client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc """
  Create a game, distributed to all nodes.
  """
  @spec create(binary()) :: term()
  def create(game_id) when is_binary(game_id) do
    GenServer.call(__MODULE__, {:create, game_id})
  end

  @doc """
  Check whether a game exist.
  """
  @spec check(binary()) :: :exist | :not_found
  def check(game_id) do
    GenServer.call(__MODULE__, {:check, game_id})
  end

  # ----------------------------------------------------------------------------------------------- server

  def init(init_arg) do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, init_arg}
  end

  def handle_info(game_id, state) when is_binary(game_id) do
    :ets.insert(@table, {game_id, self()})
    {:noreply, state}
  end

  def handle_call({:create, game_id}, _from, state) do
    PubSub.broadcast(@pubsub, @topic, game_id)
    {:reply, :ok, state}
  end

  def handle_call({:check, game_id}, _from, state) do
    res =
      case :ets.lookup(@table, game_id) do
        [] -> :not_found
        [_h | _t] -> :exist
      end

    {:reply, res, state}
  end
end
