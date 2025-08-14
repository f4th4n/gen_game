import Config

config :gen_game,
  ecto_repos: [GenGame.Repo],
  env: config_env(),
  doc_url: "https://gengame.rhinobytes.id",
  http_hook: [
    port: {:system, :integer, "HTTP_HOOK_PORT", 9500},
    host: {:system, :string, "HTTP_HOOK_HOST", "0.0.0.0"},
    scheme: {:system, :string, "HTTP_HOOK_SCHEME", "http"}
  ]

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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
config :phoenix, :logger, false

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

import_config "#{config_env()}.exs"
import_config "user.exs"
