import Config

# Configure your database
config :gen_game, GenGame.Repo,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gen_game, GenGameWeb.Endpoint,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "uvXVc7wLkpUPhvZ8rkpZ5idhay6IhACbWAvLOkoKuROJwbqaLVaeE7V7La5hVOCj",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
