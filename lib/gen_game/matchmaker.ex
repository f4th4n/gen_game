defmodule GenGame.Matchmaker do
  @moduledoc """
  Simple matchmaker process that groups compatible match requests and creates matches.
  """
  use GenServer

  require Logger

  @table :match_requests
  @interval 1_000 # 1 second
  @min_players 2  # Example: minimum players to form a match

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_tick()
    {:ok, state}
  end

  def handle_info(:tick, state) do
    # TODO: refine how we process the matchmaking requests / queue
    process_matchmaking()
    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick() do
    Process.send_after(self(), :tick, @interval)
  end

  defp process_matchmaking() do
    if :ets.whereis(@table) == :undefined, do: :ok, else: do_matchmaking()
  end

  defp do_matchmaking() do
    requests =
      :ets.tab2list(@table)
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
        :ets.insert(@table, {req.request_id, Map.put(req, :status, :match)})
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
