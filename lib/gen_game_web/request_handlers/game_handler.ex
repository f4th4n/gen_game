defmodule GenGameWeb.RequestHandlers.GameHandler do
  use GenGameWeb, :channel

  alias GenGame.Game.Gameplay
  alias GenGame.PlayerSession

  def join(match_id, token, socket) do
    with :exist <- Gameplay.check(match_id),
         {:ok, username} <- PlayerSession.verify(token) do
      send(self(), :update_presence)
      {:ok, assign(socket, match_id: match_id, username: username)}
    else
      {:error, _error} ->
        {:error, %{msg: "invalid token"}}

      :not_found ->
        {:error, %{msg: "game not found"}}
    end
  end

  def ping(_params, socket) do
    {:reply, {:ok, "pong"}, socket}
  end

  def create_game(_params, socket) do
    # TODO add option to auto start game
    match_id = Gameplay.create_game()
    {:reply, {:ok, match_id}, socket}
  end

  def set_state(%{"match_id" => match_id, "key" => key, "value" => value}, socket) do
    :ok = Gameplay.relay(match_id, key, value)
    {:reply, :ok, socket}
  end
end
