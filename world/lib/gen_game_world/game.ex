defmodule GenGameWorld.Game do
  @moduledoc """
  It's the core process that handle game state.
  """

  use GenServer
  use Memoize

  @type process_name() :: atom()
  @type token() :: binary()

  def start_link(state) do
    {name, state} = Keyword.pop(state, :name)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(_init_arg) do
    {:ok, %{nodes: []}}
  end

  # --------------------------------------------------------------------------- client

  @doc """
  create a process dynamically that handle game state with idempotency.
  """
  @spec new_game(token()) :: {:ok, pid(), atom()}
  def new_game(token) do
    case get_game(token) do
      nil ->
        game_process_name = token_to_process_name(token)
        :ets.new(game_process_name, [:set, :public, :named_table])
        DynamicSupervisor.start_child(GenGameWorld.DynamicGameSpv, {GenGameWorld.Game, [name: game_process_name]})

      pid ->
        {:ok, pid}
    end
  end

  def get_game(token) do
    token
    |> token_to_process_name()
    |> Process.whereis()
  end

  @doc """
  create node data into ets table.
  """
  @spec create_node(process_name(), struct()) :: {:ok, binary()}
  def create_node(game_process_name, node_data) do
    GenServer.call(game_process_name, {:create_node, node_data})
  end

  def handle_call({:create_node, %module{} = node_data}, _from, %{nodes: nodes} = state) do
    {:ok, pid} = DynamicSupervisor.start_child(GenGameWorld.DynamicNodesSpv, {module, node_data})
    new_node = {pid, module}
    {:reply, {:ok, new_node}, %{nodes: nodes ++ [new_node]}}
  end

  @doc """
  fetch node data from ets table.
  """
  def get_node(pid) do
    if Process.alive?(pid) do
      :sys.get_state(pid)
    else
      nil
    end
  end

  defmemo token_to_process_name(token) do
    String.to_atom("game_" <> token)
  end

  defmemo id_to_process_name(token) do
    String.to_atom("node_" <> token)
  end

  # def start_game(game_token) do
  #   GenServer.cast(__MODULE__, {:start_game, game_token})
  # end

  # --------------------------------------------------------------------------- server

  # def handle_cast({:start_game, game_token}, state) do
  #   api_node = GenGameWorld.Proxy.get_api_node()
  #   _res = :rpc.call(api_node, GenGameApi.Game, :start_game, [game_token])

  #   {:noreply, state}
  # end

  # def handle_call(:try, _from, state) do
  #   {:reply, state, state}
  # end

  def handle_cast(_, _state) do
    {:error, "unknown command"}
  end
end
