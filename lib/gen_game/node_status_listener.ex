defmodule GenGame.NodeStatusListener do
  use GenServer

  alias GenGame.Game.ServerAuthoritative

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg) do
    :net_kernel.monitor_nodes(true)
    {:ok, init_arg}
  end

  def handle_info({:nodeup, node_name}, state) do
    module = ServerAuthoritative.config() |> Keyword.get(:module)
    ping(module, node_name)

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp ping(nil, _), do: :noop

  defp ping(module, node_name) do
    case :rpc.call(node_name, module, :ping, []) do
      :pong -> :yey
      _ -> :noop
    end
  end
end
