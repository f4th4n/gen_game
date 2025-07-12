defmodule QuickArcade.CommandHandler do
  @behaviour GenGame.ServerAuthoritative

  def before_create_match(args) do
    IO.inspect("before_create_match ---------->")
    IO.inspect({"args", args})
    args
  end

  def rpc(payload) do
    IO.inspect({"rpc", payload})
    %{msg: "ffffffffffffff"}
  end

  def matchmaker_soft_expiration(payload) do
    IO.puts("[Example CommandHandler] matchmaker_soft_expiration")
    IO.inspect({"matchmaker_soft_expiration", payload})
    payload
  end

  def matchmaker_hard_expiration(payload) do
    IO.puts("[Example CommandHandler] matchmaker_hard_expiration")
    IO.inspect({"matchmaker_hard_expiration", payload})
    payload
  end
end
