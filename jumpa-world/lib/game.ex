defmodule JumpaWorld.Game do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  def new_game(game_token) do
    GenServer.cast(__MODULE__, {:new_game, game_token})
  end

  # --------------------------------------------------------------------------- server

  def handle_cast({:new_game, game_token}, state) do
    IO.inspect({":new_game, game_token, state", :new_game, game_token, state})
    api_node = JumpaWorld.Proxy.get_api_node()
    res = :rpc.call(api_node, Jumpa.Gam.games, :start_game, [game_token])
    IO.inspect({"res", res})

    {:noreply, state}
  end

  def handle_cast(_, _state) do
    {:error, "unknown command"}
  end
end
