defmodule GenGame.Application do
  @moduledoc false

  use Application

  alias GenGameWeb.Endpoint
  alias GenGame.Game.Gameplay
  alias GenGame.PlayerSession

  @impl true
  def start(_type, _args) do
    Confex.resolve_env!(:gen_game)

    children = [
      {Cluster.Supervisor, [libcluster_topology(), [name: GenGame.ClusterSupervisor]]},
      GenGameWeb.Telemetry,
      GenGame.Repo,
      {Phoenix.PubSub, name: GenGame.PubSub},
      GenGameWeb.Presence,
      Endpoint,
      PlayerSession,
      Gameplay
    ]

    opts = [strategy: :one_for_one, name: GenGame.Supervisor]
    {:ok, _pid} = res = Supervisor.start_link(children, opts)

    if Application.get_env(:gen_game, :env) == :dev do
      Gameplay.create_example_match()
    end

    res
  end

  @impl true
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
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
