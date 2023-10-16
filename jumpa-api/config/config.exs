# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :jumpa_api,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "jumpa")
      ]
    ]
  ]

# Configures the endpoint
config :jumpa_api, JumpaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: JumpaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Jumpa.PubSub,
  live_view: [signing_salt: "WrSwRop/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :jumpa_api,
  type: :api

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
