import Config

alias GenGame.Helper

config :gen_game, GenGame.Repo,
  url: System.get_env("DATABASE_URL") || raise("environment variable DATABASE_URL is missing.")

config :gen_game,
  # convert env var to config
  # env var SERVER_AUTHORITATIVE_FUNCTIONS="rpc, on_create_game"
  # becomes [:rpc, :on_create_game]
  server_authoritative_functions:
    Helper.str_to_list_of_atom(System.get_env("SERVER_AUTHORITATIVE_FUNCTIONS") || "")
