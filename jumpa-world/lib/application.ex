defmodule JumpaWorld.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:jumpa_world, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: JumpaWorld.ClusterSupervisor]]},
      Jumpa.GameSpv
    ]

    opts = [strategy: :one_for_one, name: Jumpa.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
