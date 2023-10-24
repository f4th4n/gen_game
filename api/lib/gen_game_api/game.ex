defmodule GenGameApi.Game do
  alias GenGameApi.Worker
  alias GenGameApi.Util
  alias GenGameApiApp.Game.Room

  def new_game() do
    with {:ok, %{token: token_str}} <- Worker.exec(:app, {GenGameApiApp.Game, :new_game, []}),
         {:ok, _pid} <- Worker.exec(:world, {GenGameApiWorld.Game, :new_game, [token_str]}) do
      {:ok, token_str}
    end
  end

  def get_player(id), do: exec(GenGameApiApp.Game, :get_player, [id])
  def get_player_by(query), do: exec(GenGameApiApp.Game, :get_player_by, [query])
  def get_player_by_token(player_token), do: exec(GenGameApiApp.Game, :get_player_by_token, [player_token])
  def view_player(player), do: exec(GenGameApiApp.Game, :view_player, [player])

  defp exec(m, f, a) do
    Worker.exec(:app, {m, f, a})
  end
end
