defmodule GenGameWorld.Nodes.Player do
  use GenServer

  defstruct [:id, :nick, :token, :pos_x, :pos_y]

  @type time_diff() :: non_neg_integer()
  @type delta_x() :: float()
  @type delta_y() :: float()

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @spec walk(GenServer.server(), time_diff(), delta_x(), delta_y()) :: term()
  def walk(server, time_diff, delta_x, y) do
    GenServer.call(server, {:walk, time_diff, delta_x, delta_y})
  end

  def handle_call({:walk, time_diff, delta_x, delta_y}, _from, state) do
    # TODO implement NIF here
    # new_state = Map.put(state, :pos_x, delta_x)
    {:reply, new_state, new_state}
  end
end
