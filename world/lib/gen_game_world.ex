defmodule GenGameWorld do
  use Memoize

  def get_game_pid(token) do
    token
    |> token_to_process_name()
    |> Process.whereis()
  end

  def summary() do
    %{active: active_games_count} = DynamicSupervisor.count_children(GenGameWorld.DynamicGameSpv)

    %{
      active_games_count: active_games_count
    }
  end

  def create_node(token, node_name, attrs) do
    node_data = struct(node_name, attrs)

    token
    |> token_to_process_name()
    |> GenGameWorld.Game.create_node(node_data)
  end

  def get_node(pid) do
    GenGameWorld.Game.get_node(pid)
  end

  defmemo token_to_process_name(token) do
    String.to_atom("game_" <> token)
  end
end
