defmodule Jumpa.Room do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # --------------------------------------------------------------------------- client

  def new_room(room_token) do
    GenServer.cast(__MODULE__, {:new_room, room_token})
  end

  # --------------------------------------------------------------------------- server

  def handle_cast({:new_room, room_token}, state) do
    IO.inspect({":new_room, room_token, state", :new_room, room_token, state})
    # :rpc.multicall(Node.list(), Appapi.Log.FindPayload, :start, ['13102496'])
    {:noreply, state}
  end
end
