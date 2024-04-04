defmodule GenGameWeb.RequestHandlers.GameHandler do
  use GenGameWeb, :channel

  alias GenGame.Game.Gameplay
  alias GenGame.PlayerSession
  alias Mods.Mod

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
    token = socket.assigns.token

    with {:ok, username} <- GenGame.PlayerSession.verify(token),
         match_id <- Ecto.UUID.generate(),
         _match_id <- Gameplay.create_game(username, match_id) do
      {:reply, {:ok, match_id}, socket}
    else
      _e -> {:reply, {:error, "cannot create a game"}, socket}
    end
  end

  def set_state(payload, socket) do
    match_id = socket.assigns.match_id
    Gameplay.relay(match_id, payload)
    broadcast(socket, "relay", payload)

    {:noreply, socket}
  end

  def get_state(_payload, socket) do
    match_id = socket.assigns.match_id
    game = Gameplay.get(match_id)

    {:reply, {:ok, game}, socket}
  end

  def rpc(payload, _socket) do
    Mod.rpc(payload)
  end
end
