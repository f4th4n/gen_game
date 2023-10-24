defmodule GenGameWeb.PingChannel do
  use Phoenix.Channel
  import GenGameWeb.Gettext

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("send_ping", _payload, socket) do
    {:reply, {:ok, %{ping: gettext("pong")}}, socket}
  end

  def handle_in(_, _payload, socket) do
    {:reply, {:error, "unknown command"}, socket}
  end
end
