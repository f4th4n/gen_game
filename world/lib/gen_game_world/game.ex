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
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  @doc """
  create a process dynamically that handle game state with idempotency.
  """
  @spec new_game(token()) :: {:ok, pid(), atom()}
  def new_game(token) do
    case get_game(token) do
      nil ->
        process_name = token_to_process_name(token)
        :ets.new(process_name, [:set, :public, :named_table])
        {:ok, pid} = DynamicSupervisor.start_child(GenGameWorld.DynamicGameSpv, {GenGameWorld.Game, [name: process_name]})
        {:ok, pid}

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
  def create_node(process_name, node_data) do
    id = UUID.uuid4()
    :ets.insert(process_name, {id, node_data})
    {:ok, id}
  end

  @doc """
  fetch node data from ets table.
  """
  def get_node(process_name, id) do
    case :ets.lookup(process_name, id) do
      [] -> nil
      res -> res |> List.first() |> elem(1)
    end
  end

  @doc """
  update node data in ets table.
  """
  def update_node(process_name, id, attrs) do
    case :ets.lookup(process_name, id) do
      [] ->
        nil

      res ->
        node_data = res |> List.first() |> elem(1)
        updated_node_data = Map.merge(node_data, attrs)
        :ets.insert(process_name, {id, updated_node_data})
        get_node(process_name, id)
    end
  end

  defmemo token_to_process_name(token) do
    String.to_atom("game_" <> token)
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
