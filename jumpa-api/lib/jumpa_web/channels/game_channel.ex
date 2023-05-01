defmodule JumpaWeb.GameChannel do
  use Phoenix.Channel
  alias JumpaWeb.Presence
  alias Jumpa.Repo
  alias JumpaApi.Game.Player
  alias JumpaApi.Game

  require Logger

  def join("game", %{"player_token" => player_token}, socket) do
    case Game.get_player_by_token(player_token) do
      %{id: player_id, room: %{token: room_token}} ->
        {:ok, assign(socket, :player_id, player_id)}

      _ ->
        {:error, %{msg: "Player not found"}}
    end
  end

  def join(_topic, params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  # -------------------------------------------------------------------------------- event from client start here

  def handle_in("new_game", payload, socket) do
    with :ok <- validate_player_id(socket),
         {:ok, %JumpaApi.Game.Room{} = room} <- Game.new_game() do
      res = %{room: room}
      {:reply, {:ok, res}, socket}
    end
  end

  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  defp validate_player_id(%{assigns: %{player_id: player_id}}) when is_number(player_id), do: :ok
  defp validate_player_id(_), do: :error
end
