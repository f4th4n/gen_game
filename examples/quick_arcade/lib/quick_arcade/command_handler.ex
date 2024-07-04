defmodule QuickArcade.CommandHandler do
  @behaviour GenGame.Game.ServerAuthoritative

  def before_create_match(args) do
    IO.inspect("before_create_match ---------->")
    IO.inspect({"args", args})
    args
  end

  def rpc(payload) do
    IO.inspect({"rpc", payload})
    {:ok, "ffffffffffffff"}
  end
end
