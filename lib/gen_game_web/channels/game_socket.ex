defmodule GenGameWeb.GameSocket do
  use Phoenix.Socket

  channel "account", GenGameWeb.AccountChannel
  channel "room:*", GenGameWeb.RoomChannel
  channel "benchmark:*", Benchmark.BenchmarkChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
