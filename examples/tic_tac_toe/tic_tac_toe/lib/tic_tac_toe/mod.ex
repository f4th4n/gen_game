defmodule TicTacToe.Mod do
  @behaviour GenGame.Game.Mod

  def ping(), do: :pong

  def rpc(op_code, payload) do
    IO.inspect({"op_code, payload", op_code, payload})
    {:ok, %{p1: 5050}}
  end

  def on_create_match(socket) do
    IO.inspect({"there is match", socket})
  end
end
