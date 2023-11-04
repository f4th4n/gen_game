defmodule GenGameWorld.Nodes.Player do
  use GenServer

  alias GenGameWorld.Native.AntiCheat

  defstruct [:id, :nick, :token, :pos_x, :pos_y]

  @type timelapse() :: non_neg_integer()
  @type pos_x() :: float()
  @type pos_y() :: float()

  @speed 3.0

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  @doc """
  modify player pos_x, and pos_y
  timelapse = integer, timelapse in nanoseconds
  """
  @spec walk(GenServer.server(), timelapse(), pos_x(), pos_y()) :: term()
  def walk(server, timelapse, pos_x, pos_y) do
    GenServer.call(server, {:walk, timelapse, pos_x, pos_y})
  end

  def handle_call({:walk, timelapse, after_x, after_y}, _from, %{pos_x: before_x, pos_y: before_y} = state) do
    valid_movement =
      AntiCheat.validate_player_movement(
        before_x,
        before_y,
        after_x,
        after_y,
        @speed,
        timelapse
      )

    if valid_movement do
      new_state =
        state
        |> Map.put(:pos_x, after_x)
        |> Map.put(:pos_y, after_y)

      {:reply, {:ok, new_state}, new_state}
    else
      {:reply, {:error, "invalid movement"}, state}
    end
  end
end
