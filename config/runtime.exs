import Config

if System.get_env("PHX_SERVER") do
  config :gen_game, GenGameWeb.Endpoint, server: true
end

if config_env() == :prod do
  config :gen_game, GenGame.Repo,
    url: System.get_env("DATABASE_URL") || raise("environment variable DATABASE_URL is missing.")

  config :ueberauth, Ueberauth.Strategy.Google.OAuth,
    client_id: System.get_env("GOOGLE_CLIENT_ID"),
    client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
end

log_level = System.get_env("LOG_LEVEL", "debug") |> String.to_atom()

config :logger, level: log_level
