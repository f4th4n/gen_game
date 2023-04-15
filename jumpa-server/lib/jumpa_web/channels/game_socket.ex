defmodule JumpaWeb.GameSocket do
  use Phoenix.Socket

  transport(:websocket, Phoenix.Transports.WebSocket,
    timeout: 3_000_000,
    transport_log: :debug
  )

  channel "ping", JumpaWeb.PingChannel
  channel "level:*", JumpaWeb.LevelChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
