
defmodule GenGame.Matchmaker do
  @moduledoc """
  Simple matchmaker process that groups compatible match requests and creates matches.
  Now uses Phoenix.PubSub to react to new requests in real time.
  """
  use GenServer

  require Logger

  import GenGame.ServerAuthoritative

  @table :match_requests
  alias GenGame.MatchRequests
  @min_players 2  # Example: minimum players to form a match

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  # Handle request to set up expiration timers for a match request
  def handle_cast({:setup_expiration, request_id, soft_exp, hard_exp}, state) do
    Process.send_after(self(), {:soft_expire, request_id}, soft_exp)
    Process.send_after(self(), {:hard_expire, request_id}, hard_exp)
    {:noreply, state}
  end

  # React to new match request events
  def handle_info({:new_match_request, _request_id}, state) do
    process_matchmaking()
    {:noreply, state}
  end

  # Handle soft/hard expiration events
  def handle_info({:soft_expire, request_id}, socket) do
    case MatchRequests.get_request(request_id) do
      nil -> {:noreply, socket}
      req ->
        updated = Map.put(req, :expiration_status, :soft_expired)
        MatchRequests.set_request(request_id, updated)
        dispatch_event(:matchmaker_soft_expiration, %{payload: updated, socket: socket})
        {:noreply, socket}
    end
  end

  def handle_info({:hard_expire, request_id}, socket) do
    case MatchRequests.get_request(request_id) do
      nil -> {:noreply, socket}
      req ->
        updated = Map.put(req, :expiration_status, :hard_expired)
        MatchRequests.set_request(request_id, Map.put(updated, :status, :discarded))
        dispatch_event(:matchmaker_hard_expiration, %{payload: updated, socket: socket})
        MatchRequests.delete_request(request_id)
        {:noreply, socket}
    end
  end

  # Fallback: still support :tick for manual/legacy triggers
  def handle_info(:tick, state) do
    process_matchmaking()
    {:noreply, state}
  end

  defp process_matchmaking() do
    IO.puts("[Matchmaker] Processing matchmaking...")
    if :ets.whereis(@table) == :undefined, do: :ok, else: do_matchmaking()
  end

  defp do_matchmaking() do
    IO.puts("[Matchmaker] Doing matchmaking...")
    requests =
      MatchRequests.list_requests()
      |> Enum.map(fn {_id, req} -> req end)
      |> Enum.filter(fn req -> req.status == :open and req.expiration_status == :none end)

    # Try to group compatible requests by filters
    matched_groups = group_compatible_requests(requests, @min_players)

    Enum.each(matched_groups, fn group ->
      match_id = Ecto.UUID.generate()
      usernames = Enum.map(group, & &1.user_id)
      Logger.info("[Matchmaker] Creating match #{match_id} for users #{inspect(usernames)}")
      GenGame.Game.Gameplay.create_match(Enum.join(usernames, ","), match_id)
      Enum.each(group, fn req ->
        MatchRequests.set_request(req.request_id, Map.put(req, :status, :match))
      end)
      # Optionally: notify users, dispatch event, etc.
    end)
  end

  # Group requests into lists of compatible players (by filters)
  defp group_compatible_requests(requests, min_players) do
    requests
    |> Enum.reduce({[], []}, fn req, {groups, pool} ->
      # Try to add to an existing compatible group
      case Enum.split_with(groups, fn group ->
        compatible_group?(group, req)
      end) do
        {[], _} -> {[ [req] | groups ], pool}
        {[g | rest], others} -> {[ [req | g] | rest ++ others ], pool}
      end
    end)
    |> elem(0)
    |> Enum.filter(fn group -> length(group) >= min_players end)
  end

  # TODO: verify implementation, refine, make it more extensible, etc
  # Check if a request is compatible with a group (all filters must match)
  defp compatible_group?([], _req), do: true
  defp compatible_group?([_ | _] = group, req) do
    Enum.all?(group, fn other -> compatible_filters?(other.filters, req.filters) end)
  end

  # Check if two filter lists are compatible
  defp compatible_filters?(filters1, filters2) do
    Enum.all?(filters1, fn f1 ->
      Enum.any?(filters2, fn f2 -> filter_compatible?(f1, f2) end)
    end)
  end

  # Check if two filter maps are compatible (support mmr, region, game_mode)
  defp filter_compatible?(%{"attribute" => "mmr", "min" => min1, "max" => max1}, %{"attribute" => "mmr", "min" => min2, "max" => max2}) do
    not (max1 < min2 or max2 < min1)
  end
  defp filter_compatible?(%{"attribute" => "region", "string-equals" => r1}, %{"attribute" => "region", "string-equals" => r2}) do
    r1 == r2
  end
  defp filter_compatible?(%{"attribute" => "game_mode", "string-in" => modes1}, %{"attribute" => "game_mode", "string-in" => modes2}) do
    Enum.any?(modes1, fn m -> m in modes2 end)
  end
  defp filter_compatible?(_, _), do: false
end
