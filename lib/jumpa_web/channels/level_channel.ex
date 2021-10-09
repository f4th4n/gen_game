defmodule JumpaWeb.LevelChannel do
  use Phoenix.Channel
  import JumpaWeb.Gettext
  alias JumpaWeb.Presence
  alias Jumpa.Repo

  intercept ["request_ping"]

  # def join(_topic, _payload, socket) do
  #  {:ok, socket}
  # end
  def join(_topic, _params, socket) do
    room_id = "1"
    send(self(), :after_join)
    {:ok, %{channel: "room:#{room_id}"}, assign(socket, :room_id, room_id)}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    user = Repo.get(User, socket.assigns[:current_user_id])

    {:ok, _} =
      Presence.track(socket, "user:#{user.id}", %{
        user_id: user.id,
        username: user.username
      })

    {:noreply, socket}
  end

  def handle_in("walk", _payload, socket) do
    {:reply, {:ok, %{ping: gettext("walk to the fire")}}, socket}
  end

  def handle_out("request_ping", payload, socket) do
    push(socket, "send_ping", Map.put(payload, "from_node", Node.self()))
    {:noreply, socket}
  end
end
