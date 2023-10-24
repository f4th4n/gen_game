import Config

# Configure your database
config :gen_game_app, GenGameApp.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
