defmodule GenGame.Repo do
  use Ecto.Repo,
    otp_app: :gen_game,
    adapter: Ecto.Adapters.Postgres
end
