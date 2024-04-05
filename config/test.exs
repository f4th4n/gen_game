import Config

config :gen_game, GenGame.Repo,
  url: "ecto://postgres:postgres@localhost/gen_game_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gen_game, GenGameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ZWnmS0/Qm8QelvF3UIV4yQjViLSyC9/bn5DpLLM/XBBtXj4QQ19w5qi/5bZtZq0g",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
