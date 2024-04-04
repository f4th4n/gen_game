import Config

config :gen_game,
  ecto_repos: [GenGame.Repo],
  generators: [timestamp_type: :utc_datetime],
  env: config_env()

config :gen_game, GenGameWeb.Endpoint,
  url: [host: "localhost"],
  http: [ip: {0, 0, 0, 0}, port: {:system, :integer, "HTTP_PORT", 4000}],
  check_origin: false,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: GenGameWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GenGame.PubSub,
  live_view: [signing_salt: "MQtVmOzM"],
  secret_key_base: {:system, "SECRET_KEY_BASE"}

config :gen_game, GenGame.Repo, url: {:system, "DATABASE_URL"}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
