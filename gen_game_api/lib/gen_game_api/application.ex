defmodule GenGameApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:gen_game_api, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: GenGameApi.ClusterSupervisor]]},
      {Phoenix.PubSub, name: GenGameApi.PubSub},
      GenGameWeb.Telemetry,
      GenGameWeb.Endpoint,
      GenGameWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: GenGameApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GenGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
