defmodule GenGame.Game.ServerAuthoritative do
  @moduledoc """
  """

  def rpc(_username) do
    # TODO
  end

  def on_create_match(_username) do
    # TODO
  end

  def config() do
    module = Application.get_env(:gen_game, :server_authoritative_module)
    functions = Application.get_env(:gen_game, :server_authoritative_functions)
    [module: module, functions: functions]
  end
end
