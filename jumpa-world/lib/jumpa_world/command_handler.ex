defmodule JumpaWorld.CommandHandler do
	use GenServer

	def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
	end

	def init(init_arg) do
		Phoenix.PubSub.subscribe(Jumpa.PubSub, "user:123")
		Phoenix.PubSub.subscribe(Jumpa.PubSub, "room:*")

		{:ok, init_arg}
	end

	def handle_info(msg, state) do
		IO.inspect({"msg", msg})
		{:noreply, state}
	end
end