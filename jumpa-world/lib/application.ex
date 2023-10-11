defmodule JumpaWorld.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:jumpa_world, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: JumpaWorld.ClusterSupervisor]]},
      JumpaWorld.GameSpv,
      {Phoenix.PubSub, name: Jumpa.PubSub},
      JumpaWorld.CommandHandler
    ]

    Logger.info("jumpa world started...")
    opts = [strategy: :one_for_one, name: JumpaWorld.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
