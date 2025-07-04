import Config

if System.get_env("PHX_SERVER") do
  config :gen_game, GenGameWeb.Endpoint, server: true
end

if config_env() == :prod do
  config :gen_game, GenGame.Repo,
    url: System.get_env("DATABASE_URL") || raise("environment variable DATABASE_URL is missing.")
end

log_level = System.get_env("LOG_LEVEL", "debug") |> String.to_atom()

config :logger, level: log_level
