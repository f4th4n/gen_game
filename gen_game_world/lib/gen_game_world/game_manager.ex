defmodule GenGameWorld.GameManager do
  use GenServer

  alias GenGameWorld.Worker

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    GenServer.cast(__MODULE__, :hydrate)
    {:ok, init_arg}
  end

  def handle_cast(:hydrate, state) do
    case hydrate() do
      {:bad_rpc, _} ->
        :timer.sleep(500)
        GenServer.cast(__MODULE__, :hydrate)

      _ ->
        :noop
    end

    {:noreply, state}
  end

  defp hydrate() do
    with games = [_h | _t] <- Worker.exec(:app, {GenGameApp.Game.Rooms, :find, [[status: :started]]}) do
      create_games(games)
    end
  end

  defp create_games(games) do
    games
    |> Enum.map(fn game ->
      {:ok, _pid, _process_name} = GenGameWorld.Game.new_game(game.token)
    end)
  end
end
