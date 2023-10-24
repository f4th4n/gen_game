defmodule GenGameApp.Repo do
  use Ecto.Repo,
    otp_app: :gen_game_app,
    adapter: Ecto.Adapters.Postgres
end
