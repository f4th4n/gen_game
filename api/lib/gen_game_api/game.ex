defmodule GenGameApi.Game do
  alias GenGameApi.Rpc
  alias GenGameApi.Util
  alias GenGameApp.Game.Room

  def new_game() do
    with {:ok, %{token: token_str}} <- Rpc.exec(:app, {GenGameApp.Game, :new_game, []}) do
      {:ok, token_str}
    end
  end

  def get_player(id), do: exec(GenGameApp.Game, :get_player, [id])
  def get_player_by(query), do: exec(GenGameApp.Game, :get_player_by, [query])
  def get_player_by_token(player_token), do: exec(GenGameApp.Game, :get_player_by_token, [player_token])
  def view_player(player), do: exec(GenGameApp.Game, :view_player, [player])

  defp exec(m, f, a) do
    Rpc.exec(:app, {m, f, a})
  end
end
