defmodule GenGameWeb.RequestHandlers.GameHandler do
  use GenGameWeb, :channel

  require Logger

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

  def create_match(_params, socket) do
    # TODO add option to auto start game
    token = socket.assigns.token

    with {:ok, username} <- GenGame.PlayerSession.verify(token),
         match_id <- Ecto.UUID.generate(),
         _match_id <- Gameplay.create_match(username, match_id) do
      {:reply, {:ok, match_id}, socket}
    else
      e ->
        Logger.error("[GameHandler] create_match error: #{inspect(e)}")
        {:reply, {:error, "cannot create a game"}, socket}
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

  def rpc(payload, socket) do
    server_authoritative = socket.assigns.server_authoritative
    IO.inspect({"rpc", payload})
    IO.inspect({"mfa", server_authoritative})

    {:reply, {:ok, :ff}, socket}
  end
end
