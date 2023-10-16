defmodule JumpaApp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.fetch_env!(:jumpa_app, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: JumpaApp.ClusterSupervisor]]},
      {Phoenix.PubSub, name: Jumpa.PubSub},
      JumpaApp.Repo,
    ]

    opts = [strategy: :one_for_one, name: JumpaApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
