defmodule JumpaWeb.PingChannel do
  use Phoenix.Channel

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("send_ping", _payload, socket) do
    {:reply, {:ok, %{ping: "  pong"}}, socket}
  end
end
