defmodule JumpaWeb.LevelChannel do
  use Phoenix.Channel
  import JumpaWeb.Gettext

  intercept ["request_ping"]

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("walk", _payload, socket) do
    {:reply, {:ok, %{ping: gettext("walk to the fire")}}, socket}
  end

  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
