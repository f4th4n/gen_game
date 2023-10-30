defmodule GenGameWorld.Rpc do
	@type app() :: :api|:app|:world

	@spec exec(atom(), list()) :: any()
	def exec(app, {m, f, a}) do
		case get_node(app) do
			nil -> {:bad_rpc, {:no_node, app}}
			node_name ->
				:rpc.call(node_name, m, f, a)
		end
	end

  @spec get_node(app(), string()) :: nil|atom()
  def get_node(app, key \\ nil) do
    case get_nodes(app) do
      [] -> nil
      nodes -> pick_node(nodes, key)
    end
  end

  @spec get_nodes(app()) :: list()
	def get_nodes(app) do
    Node.list()
    |> Enum.filter(fn node -> find_nodes_by_type(node, app) end)
	end

  def find_nodes_by_type(node_name, type) do
    config_key =
      case type do
        :world -> :gen_game_world
        :api -> :gen_game_api
        :app -> :gen_game_app
      end

    case :rpc.call(node_name, Application, :fetch_env, [config_key, :type]) do
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