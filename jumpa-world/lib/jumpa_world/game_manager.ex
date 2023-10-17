defmodule JumpaWorld.GameManager do
	use GenServer

	alias JumpaWorld.Worker

	def start_link(init_arg) do
		GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
	end

	def init(init_arg) do
		{:ok, init_arg, {:continue, :start_games}}
	end

	def handle_continue(:start_games, state) do
		with games <- Worker.exec(:app, {JumpaApp.Game.Rooms, :find, [[status: :started]]}) do
			IO.inspect({"games", games})
		end

		{:noreply, state}
	end
end