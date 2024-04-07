defmodule GenGameWeb.GameSocket do
  use Phoenix.Socket

  alias GenGame.Game.ServerAuthoritative
  alias GenGameWeb.Channels.PublicChannel
  alias GenGameWeb.Channels.GenGameChannel
  alias GenGameWeb.Channels.GameplayChannel
  alias Benchmark.BenchmarkChannel

  channel "public", PublicChannel
  channel "gg", GenGameChannel
  channel "game:*", GameplayChannel
  channel "benchmark:*", BenchmarkChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, assign(socket, server_authoritative: ServerAuthoritative.config())}
  end

  @impl true
  def id(_socket), do: nil
end
