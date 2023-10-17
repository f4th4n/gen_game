defmodule JumpaWeb.GameChannel do
  use Phoenix.Channel

  alias JumpaApi.Game
  alias JumpaApi.Game.Room

  require Logger

  def join("game", %{"player_token" => player_token}, socket) do
    case Game.get_player_by_token(player_token) do
      %{id: player_id, room: %{token: _room_token}} ->
        {:ok, assign(socket, :player_id, player_id)}

      _ ->
        {:error, %{msg: "Player not found"}}
    end
  end

  def join(_topic, _params, _socket) do
    {:error, %{code: 100, msg: "wrong parameters"}}
  end

  # -------------------------------------------------------------------------------- event from client start here

  def handle_in("new_game", _payload, socket) do
    with :ok <- validate_player_id(socket),
         {:ok, token} <- Game.new_game() do
      {:reply, {:ok, %{token: token}}, socket}
    else
      {:rpc_error, :no_worker} ->
        # {:rpc_error, :no_worker}
        Logger.info("error create new game, reason: #{inspect({:rpc_error, :no_worker})}")
        {:reply, {:error, :rpc_error}}
      e ->
        # {:rpc_error, :no_worker}
        Logger.info("error create new game, reason: #{inspect(e)}")
        {:reply, {:error, :unknown_error}}
    end
  end

  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  defp validate_player_id(%{assigns: %{player_id: player_id}}) when is_number(player_id), do: :ok
  defp validate_player_id(_), do: :error
end
