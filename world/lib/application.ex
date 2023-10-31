defmodule GenGameWorld.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:gen_game_world, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: GenGameWorld.ClusterSupervisor]]},
      {Phoenix.PubSub, name: GenGame.PubSub},
      GenGameWorld.GameSpv,
      GenGameWorld.CommandHandler
    ]

    Logger.info("gen_game_world started...")
    opts = [strategy: :one_for_one, name: GenGameWorld.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
