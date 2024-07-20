defmodule QuickArcade.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("QuickArcade start")

    children = [
      {Cluster.Supervisor, [libcluster_topology(), [name: GenGame.ClusterSupervisor]]},
    ]

    opts = [strategy: :one_for_one, name: QuickArcade.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp libcluster_topology() do
    [
      gossip: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          secret: "gen_game_secret_1020"
        ]
      ]
    ]
  end
end
