defmodule GenGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Confex.resolve_env!(:gen_game)

    children = [
      {Cluster.Supervisor, libcluster_config()},
      GenGameWeb.Telemetry,
      GenGame.Repo,
      {Phoenix.PubSub, name: GenGame.PubSub},
      GenGameWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GenGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GenGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp libcluster_config() do
    [
      [gen_game: [strategy: Cluster.Strategy.LocalEpmd]],
      [name: GenGame.ClusterSupervisor]
    ]
  end
end
