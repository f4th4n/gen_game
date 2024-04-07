defmodule GenGame.Game.Mod do
  @callback ping() :: :pong
  @callback rpc() :: term()

  @optional_callbacks rpc: 0
end
