import Config

# Configure your database
config :jumpa_app, JumpaApp.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
