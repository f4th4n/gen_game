import Config

# alias GenGame.Helper

config :gen_game, GenGame.Repo,
  url: System.get_env("DATABASE_URL") || raise("environment variable DATABASE_URL is missing.")
