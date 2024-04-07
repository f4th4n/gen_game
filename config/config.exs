import Config

# `server_authoritative_module` is module name on the another node in the same cluster that will be called
# when some events happened.
# For example when a match is created, and `server_authoritative_module` set to `TicTacToe.Mod` then this node will call `TicTacToe.Mod.rpc`
config :gen_game,
  ecto_repos: [GenGame.Repo],
  env: config_env(),
  server_authoritative_module: {:system, :module, "SERVER_AUTHORITATIVE_MODULE", nil},
  # filled at runtime.exs
  server_authoritative_functions: []

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

import_config "#{config_env()}.exs"
import_config "user.exs"
