import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :jumpa_app, JumpaApp.Repo,
  # ssl: true,
  # socket_options: [:inet6],
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
