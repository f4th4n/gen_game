defmodule Jumpa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
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
      JumpaWeb.Endpoint
      # Start a worker by calling: Jumpa.Worker.start_link(arg)
      # {Jumpa.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jumpa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JumpaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
