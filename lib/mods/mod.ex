defmodule Mods.Mod do
  # use GenServer

  def rpc(payload) do
    IO.inspect({"payload", payload})
  end
end
