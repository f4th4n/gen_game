defmodule GenGameWorld.Nodes.Player do
	use GenServer

	defstruct [:id, :nick, :token, :pos_x, :pos_y]

	def start_link(state) do
    {name, state} = Keyword.pop(state, :name)
    GenServer.start_link(__MODULE__, state, name: name)
  end
end