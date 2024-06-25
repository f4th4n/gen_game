defmodule GenGame.PluginNodeListener do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def all() do
    GenServer.call(__MODULE__, :get_nodes)
  end

  @impl true
  def init(_) do
    :net_kernel.monitor_nodes(true)
    nodes = Node.list() |> Enum.map(&store_node(&1, [])) |> List.flatten()
    {:ok, %{nodes: nodes}}
  end

  @impl true
  def handle_call(:get_nodes, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info({:nodeup, node}, %{nodes: nodes} = state) do
    nodes = Enum.uniq(nodes ++ [node])
    {:noreply, Map.put(state, :nodes, nodes)}
  end

  def handle_info({:nodedown, node}, %{nodes: nodes} = state) do
    nodes = List.delete(nodes, node)
    {:noreply, Map.put(state, :nodes, nodes)}
  end

  defp store_node(node_name, nodes) do
    if is_plugin_node?(node_name) do
      Enum.uniq(nodes ++ [node_name])
    else
      nodes
    end
  end

  defp is_plugin_node?(node_name) do
    case :rpc.call(node_name, Application, :get_env, [:gen_game, :mode]) do
      :plugin -> true
      nil -> false
    end
  end
end
