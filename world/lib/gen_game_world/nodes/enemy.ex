defmodule GenGameWorld.Nodes.Enemy do
	# use GenServer

	defstruct [:id, :hp, :damage, :pos_x, :pos_y, :meta]

	# def start_link(state) do
  #   {name, state} = Keyword.pop(state, :name)
  #   GenServer.start_link(__MODULE__, state, name: name)
  # end
end