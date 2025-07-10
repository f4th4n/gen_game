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

  # In-memory store for match requests (for demo, replace with persistent store in production)
  defp now(), do: :os.system_time(:millisecond)

  defp default_soft_expiration(), do: 5_000
  defp default_hard_expiration(), do: 10_000

  defp put_request(request_id, data) do
    # TODO: store in postgres instead of ETS for persistence
    :ets.insert(:match_requests, {request_id, data})
  end

  defp get_request(request_id) do
    case :ets.lookup(:match_requests, request_id) do
      [{^request_id, data}] -> data
      _ -> nil
    end
  end

  defp delete_request(request_id), do: :ets.delete(:match_requests, request_id)

  defp ensure_table() do
    if :ets.whereis(:match_requests) == :undefined do
      :ets.new(:match_requests, [:named_table, :public, :set])
    end
  end

  def request_match(params, socket) do
    ensure_table()
    token = socket.assigns.token
    with {:ok, user_id} <- PlayerSession.verify(token) do
      started_at = now()
      soft_exp = Map.get(params, "soft_expiration", default_soft_expiration())
      hard_exp = Map.get(params, "hard_expiration", default_hard_expiration())
      filters = Map.get(params, "filters", [])
      request_id = Ecto.UUID.generate()
      match_request = %{
        request_id: request_id,
        user_id: user_id,
        filters: filters,
        started_at: started_at,
        status: :open,
        expiration_status: :none,
        soft_expiration: soft_exp,
        hard_expiration: hard_exp
      }
      put_request(request_id, match_request)

      # Dispatch new request hook
      dispatch_event(:matchmaker_new_request, Map.put(match_request, :socket, socket))

      # Set up soft/hard expiration timers
      # TODO: rethink how to handle expiration, maybe there's a better way to do this?
      Process.send_after(self(), {:soft_expire, request_id}, soft_exp)
      Process.send_after(self(), {:hard_expire, request_id}, hard_exp)

      {:reply, {:ok, match_request}, socket}
    else
      e ->
        Logger.error("[GameHandler] request_match error: #{inspect(e)}")
        {:reply, {:error, "cannot request match"}, socket}
    end
  end

  # Handle soft/hard expiration events
  def handle_info({:soft_expire, request_id}, socket) do
    case get_request(request_id) do
      nil -> {:noreply, socket}
      req ->
        updated = Map.put(req, :expiration_status, :soft_expired)
        put_request(request_id, updated)
        dispatch_event(:matchmaker_soft_expiration, Map.put(updated, :socket, socket))
        {:noreply, socket}
    end
  end

  def handle_info({:hard_expire, request_id}, socket) do
    case get_request(request_id) do
      nil -> {:noreply, socket}
      req ->
        updated = Map.put(req, :expiration_status, :hard_expired)
        put_request(request_id, Map.put(updated, :status, :discarded))
        dispatch_event(:matchmaker_hard_expiration, Map.put(updated, :socket, socket))
        delete_request(request_id)
        {:noreply, socket}
    end
  end
end
