defmodule GenGame.Hooks.NodeListener do
  @moduledoc """
  state = %{
    nodes: list of valid hook nodes
    hook_actions: a config fetched from remote node, it is list of actions that will be called when there is event fired
  }
  """

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{nodes: [], hook_actions: []}, name: __MODULE__)
  end

  def hook_actions() do
    GenServer.call(__MODULE__, :hook_actions)
  end

  def get() do
    GenServer.call(__MODULE__, :get_node)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @impl true
  def init(args) do
    :net_kernel.monitor_nodes(true)

    state =
      case Node.list() do
        [] ->
          args

        nodes ->
          hook_actions =
            nodes
            |> List.first()
            |> get_hook_actions_config()

          %{nodes: nodes, hook_actions: hook_actions}
      end

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_node, _from, %{nodes: nodes} = state) do
    reply =
      case nodes do
        [] -> {:error, :no_node}
        nodes -> {:ok, List.first(nodes)}
      end

    {:reply, reply, state}
  end

  def handle_call(:hook_actions, _from, %{hook_actions: hook_actions} = state) do
    reply =
      case hook_actions do
        [] -> {:error, :no_hook_actions}
        lst -> {:ok, lst}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    state = update_state(node, state)
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, %{nodes: nodes} = state) do
    nodes = List.delete(nodes, node)
    state = Map.put(state, :nodes, nodes)
    {:noreply, state}
  end

  defp update_state(node, %{nodes: nodes} = state) do
    updated_nodes = node |> append_node(nodes) |> Enum.uniq()
    hook_actions = get_hook_actions_config(node)

    state
    |> Map.put(:nodes, updated_nodes)
    |> Map.put(:hook_actions, hook_actions)
  end

  defp append_node(node_name, nodes) do
    if is_hook_node?(node_name) do
      Enum.uniq(nodes ++ [node_name])
    else
      nodes
    end
  end

  defp is_hook_node?(node_name) do
    case :rpc.call(node_name, Application, :get_env, [:gen_game, :mode]) do
      :hook -> true
      nil -> false
    end
  end

  defp get_hook_actions_config(node_name) do
    case :rpc.call(node_name, Application, :get_env, [:gen_game, :hook_actions]) do
      hook_actions -> hook_actions
    end
  end
end
