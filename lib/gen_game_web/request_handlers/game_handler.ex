defmodule GenGameWeb.RequestHandlers.GameHandler do
  use GenGameWeb, :channel

  require Logger

  import GenGame.ServerAuthoritative

  alias GenGame.Game.Gameplay
  alias GenGame.PlayerSession

  def join(match_id, token, socket) do
    Logger.info("[GameHandler] join topic GameHandler, match_id=#{match_id}")

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
         {:ok,
          %{
            username: username,
            match_id: match_id,
            socket: socket
          }} <-
           dispatch_event(:before_create_match, %{
             username: username,
             match_id: match_id,
             socket: socket
           }),
         _match_id <- Gameplay.create_match(username, match_id),
         {:ok, _} <-
           dispatch_event(:after_create_match, %{
             username: username,
             match_id: match_id,
             socket: socket
           }) do
      Logger.info("[GameHandler] create match, match_id=#{match_id}")
      reply = %{match_id: match_id}
      {:reply, {:ok, reply}, socket}
    else
      e ->
        Logger.error("[GameHandler] create match error: #{inspect(e)}")
        {:reply, {:error, "cannot create a game"}, socket}
    end
  end

  def get_last_match_id(_params, socket) do
    reply = Gameplay.get_last_match_id()
    Logger.info("[GameHandler] get_last_match_id")
    {:reply, {:ok, reply}, socket}
  end

  def set_state(payload, socket) do
    match_id = socket.assigns.match_id
    Gameplay.relay(match_id, payload)

    # TODO change relay to onChangeState
    broadcast(socket, "relay", payload)

    Logger.info("[GameHandler] set state, match_id=#{match_id} payload=#{inspect(payload)}")

    {:noreply, socket}
  end

  def get_state(_payload, socket) do
    match_id = socket.assigns.match_id
    game = Gameplay.get(match_id)

    Logger.info("[GameHandler] get state, match_id=#{match_id}")

    {:reply, {:ok, game}, socket}
  end

  def rpc(payload, socket) do
    Logger.info("[GameHandler] call rpc, payload=#{inspect(payload)}")

    reply =
      case dispatch_event(:rpc, %{payload: payload, socket: socket}) do
        {:ok, res} ->
          {:ok, res}

        {:error, error} ->
          Logger.error("[rpc] error #{error}")

          {:error, error}
      end

    {:reply, reply, socket}
  end
end
