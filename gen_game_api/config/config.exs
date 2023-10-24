# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :gen_game_api,
  topologies: [
    gossip: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        secret: System.get_env("RELEASE_COOKIE", "GenGameApi")
      ]
    ]
  ]

# Configures the endpoint
config :gen_game_api, GenGameWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GenGameWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: GenGameApi.PubSub,
  live_view: [signing_salt: "WrSwRop/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :gen_game_api,
  type: :api

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
