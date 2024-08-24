defmodule GenGameWeb.GameSocket do
  use Phoenix.Socket

  require Logger

  alias GenGameWeb.Channels.PublicChannel
  alias GenGameWeb.Channels.GenGameChannel
  alias GenGameWeb.Channels.GameChannel
  alias Benchmark.BenchmarkChannel

  channel "public", PublicChannel
  channel "gen_game", GenGameChannel
  channel "game:*", GameChannel
  channel "benchmark:*", BenchmarkChannel

  @impl true
  def connect(params, socket, _connect_info) do
    Logger.info("[GameSocket] join socket, params=#{inspect(params)}")
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
