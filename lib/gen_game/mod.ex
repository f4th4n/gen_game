defmodule GenGame.Mod do
  @moduledoc """
  Implementation of server authoritative. You can edit this module freely. Function init/0 will be called after application initialized.
  """

  @behaviour GenGame.Game.ServerAuthoritative

  def init(), do: :ok

  def rpc(args) do
    payload = Keyword.get(args, :payload)
    {:ok, %{payload: payload}}
  end
end
