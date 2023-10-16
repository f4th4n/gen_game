defmodule JumpaApp.Repo do
  use Ecto.Repo,
    otp_app: :jumpa_app,
    adapter: Ecto.Adapters.Postgres
end
