defmodule GenGameWorld do
  def get_game_pid(token_str) do
    token = String.to_atom("game_" <> token_str)
    Process.whereis(token)
  end

  def summary() do
    %{active: active_games_count} = DynamicSupervisor.count_children(GenGameWorld.DynamicGameSpv)

    %{
      active_games_count: active_games_count
    }
  end

  def get_node(process_name, id) do
    GenGameWorld.Game.get_node(process_name, id)
  end

  def create_node(process_name, node_name, attrs) do
    node_data = struct(node_name, attrs)
    GenGameWorld.Game.create_node(process_name, node_data)
  end

  def update_node(id, attrs) do
  end
end
