defmodule JumpaWorld.Proxy do
  def get_api_node(key \\ nil) do
    case get_api_nodes() do
      [] -> nil
      nodes -> pick_node(nodes, key)
    end
  end

  def get_api_nodes() do
    Node.list()
    |> Enum.filter(fn node -> find_nodes_by_type(node, :api) end)
  end

  def find_nodes_by_type(node, type) do
    config_key =
      case type do
        :world -> :jumpa_world
        :api -> :jumpa_api
      end

    case :rpc.call(node, Application, :fetch_env, [config_key, :type]) do
      {:ok, _type} -> true
      _ -> false
    end
  end

  defp pick_node(nodes, nil), do: List.first(nodes)

  defp pick_node(nodes, key) do
    hash = :erlang.phash2(key)
    node_count = Enum.count(nodes)
    index = rem(hash, node_count)
    Enum.at(nodes, index)
  end
end
