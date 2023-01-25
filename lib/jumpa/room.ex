defmodule Jumpa.Room do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :reply_is_this, 8888}
  end

  def handle_call(:print, _from, state) do
    IO.inspect({"start print"})
    :timer.sleep(:timer.seconds(4))
    IO.inspect({"after print"})
    {:reply, state, state}
  end

  def handle_cast(:print, state) do
    IO.inspect({"start print"})
    :timer.sleep(:timer.seconds(4))
    IO.inspect({"after print"})
    {:noreply, state}
  end

  def handle_info(1, state) do
    IO.inspect({"1 handle_info called", 1})
    :timer.sleep(:timer.seconds(5))
    IO.inspect("after sleep")

    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect({"2 handle_info called", 2})
    :timer.sleep(:timer.seconds(5))
    IO.inspect("after sleep")

    {:noreply, state}
  end
end
