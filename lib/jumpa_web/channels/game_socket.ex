defmodule JumpaWeb.GameSocket do
  use Phoenix.Socket

  channel "ping", JumpaWeb.PingChannel
  channel "level", JumpaWeb.LevelChannel
  # TODO add room channel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
