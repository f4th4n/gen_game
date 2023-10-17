defmodule JumpaApi.Game do
  alias JumpaApi.Worker
  alias JumpaApi.Util
  alias JumpaApp.Game.Room

  def new_game() do
    with {:ok, %{token: token_str}} <- Worker.exec(:app, {JumpaApp.Game, :new_game, []}),
         token <- String.to_atom(token_str),
         {:ok, _pid} <- Worker.exec(:world, {JumpaWorld.Game, :new_game, [token]}) do
      {:ok, token}
    end
  end
end
