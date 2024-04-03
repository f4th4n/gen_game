defmodule GenGameWeb.GameSocket do
  use Phoenix.Socket

  alias GenGameWeb.Channels.GenGameChannel
  alias GenGameWeb.Channels.GameplayChannel
  alias Benchmark.BenchmarkChannel

  channel "gg", GenGameChannel
  channel "gg:game:*", GameplayChannel
  channel "benchmark:*", BenchmarkChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
