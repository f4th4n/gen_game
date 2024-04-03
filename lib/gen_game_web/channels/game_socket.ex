defmodule GenGameWeb.GameSocket do
  use Phoenix.Socket

  channel "auth", GenGameWeb.AuthChannel
  channel "account", GenGameWeb.AccountChannel
  channel "game:*", GenGameWeb.GameplayChannel
  channel "benchmark:*", Benchmark.BenchmarkChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
