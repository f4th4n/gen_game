defmodule GenGameWorld.Game do
  use GenServer

  def start_link(state) do
    {name, state} = Keyword.pop(state, :name)
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  @spec new_game(binary()) :: {:ok, pid(), atom()}
  def new_game(token_str) do
    process_name = String.to_atom("game_" <> token_str)
    {:ok, pid} = DynamicSupervisor.start_child(GenGameWorld.DynamicGameSpv, {GenGameWorld.Game, [name: process_name]})
    {:ok, pid, process_name}
  end

  def start_game(game_token) do
    GenServer.cast(__MODULE__, {:start_game, game_token})
  end

  # --------------------------------------------------------------------------- server

  def handle_cast({:start_game, game_token}, state) do
    api_node = GenGameWorld.Proxy.get_api_node()
    _res = :rpc.call(api_node, GenGameApi.Game, :start_game, [game_token])

    {:noreply, state}
  end

  def handle_call(:try, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(_, _state) do
    {:error, "unknown command"}
  end
end
