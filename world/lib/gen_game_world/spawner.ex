defmodule GenGameWorld.Spawner do
  use GenServer

  @polling_frequency 1000

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg, {:continue, :start_spawner}}
  end

  def handle_continue(:start_spawner, state) do
    schedule_api_call()
    {:noreply, state}
  end

  defp schedule_api_call(delay \\ @polling_frequency) do
    Process.send_after(self(), :do_api_call, delay)
  end
end
