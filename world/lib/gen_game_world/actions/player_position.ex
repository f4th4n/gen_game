# TODO not implemented

defmodule GenGameWorld.Actions.PlayerPosition do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  def move(game_token, x, y) do
    GenServer.cast(__MODULE__, {:player_position, game_token})
  end

  # --------------------------------------------------------------------------- server

  def handle_cast({:player_position, game_token}, state) do
    api_node = GenGameWorld.Proxy.get_api_node()
    _res = :rpc.call(api_node, GenGameApi.Game, :player_position, [game_token])

    {:noreply, state}
  end

  def handle_cast(_, _state) do
    {:error, "unknown command"}
  end
end
