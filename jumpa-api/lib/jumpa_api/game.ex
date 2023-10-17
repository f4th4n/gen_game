defmodule JumpaApi.Game do
  alias JumpaApi.Worker
  alias JumpaApi.Util
  alias JumpaApp.Game.Room

  def new_game() do
    with {:ok, %{token: token_str}} <- Worker.exec(:app, {JumpaApp.Game, :new_game, []}),,
         {:ok, _pid} <- Worker.exec(:world, {JumpaWorld.Game, :new_game, [token_str]}) do
      {:ok, token}
    end
  end

  def get_player(id), do: exec(JumpaApp.Game, :get_player, [id])
  def get_player_by(query), do: exec(JumpaApp.Game, :get_player_by, [query])
  def get_player_by_token(player_token), do: exec(JumpaApp.Game, :get_player_by_token, [player_token])
  def view_player(player), do: exec(JumpaApp.Game, :view_player, [player])

  defp exec(m, f, a) do
    Worker.exec(:app, {m, f, a})
  end
end
