defmodule Jumpa.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Jumpa.Repo,
      # Start the Telemetry supervisor
      JumpaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Jumpa.PubSub},
      # Start the Endpoint (http/https)
      JumpaWeb.Endpoint,
      # supervisor(JumpaWeb.Presence, [])
      JumpaWeb.Presence,
      # Start a worker by calling: Jumpa.Worker.start_link(arg)
      # {Jumpa.Worker, arg}
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
