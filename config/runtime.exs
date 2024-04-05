import Config

config :gen_game, GenGame.Repo, url: System.get_env("DATABASE_URL")
