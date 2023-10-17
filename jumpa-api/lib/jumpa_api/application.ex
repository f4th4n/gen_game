defmodule JumpaApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:jumpa_api, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: JumpaApi.ClusterSupervisor]]},
      {Phoenix.PubSub, name: Jumpa.PubSub},
      JumpaWeb.Telemetry,
      JumpaWeb.Endpoint,
      JumpaWeb.Presence
    ]

    opts = [strategy: :one_for_one, name: Jumpa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    JumpaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
