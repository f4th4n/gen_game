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
end
