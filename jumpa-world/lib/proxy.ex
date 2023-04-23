defmodule JumpaWorld.Proxy do
  def get_api_node() do
    case get_api_nodes() do
    	nil -> nil
    	nodes -> List.first(nodes)
    end
  end

  def get_api_nodes() do
    Node.list()
    |> Enum.filter(fn node -> find_nodes_by_type(node, :api) end)
  end

  def find_nodes_by_type(node, type) do
    config_key = case type do
      :world -> :jumpa_world
      :api -> :jumpa_api
    end

    case :rpc.call(node, Application, :fetch_env, [config_key, :type]) do
      {:ok, type} -> true
      _ -> false
    end
  end
end
