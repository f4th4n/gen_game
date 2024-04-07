defmodule TicTacToe.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [libcluster_topology(), [name: GenGame.ClusterSupervisor]]},
    ]

    opts = [strategy: :one_for_one, name: TicTacToe.Supervisor]
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
