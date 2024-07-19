import Config

if System.get_env("PHX_SERVER") do
  config :gen_game, GenGameWeb.Endpoint, server: true
end

config :gen_game, GenGame.Repo,
  url: System.get_env("DATABASE_URL") || raise("environment variable DATABASE_URL is missing.")
