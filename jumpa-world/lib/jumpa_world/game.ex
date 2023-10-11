defmodule JumpaWorld.Game do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  def start_game(game_token) do
    GenServer.cast(__MODULE__, {:start_game, game_token})
  end

  # --------------------------------------------------------------------------- server

  def handle_cast({:start_game, game_token}, state) do
    api_node = JumpaWorld.Proxy.get_api_node()
    _res = :rpc.call(api_node, JumpaApi.Game, :start_game, [game_token])

    {:noreply, state}
  end

  def handle_cast(_, _state) do
    {:error, "unknown command"}
  end
end
