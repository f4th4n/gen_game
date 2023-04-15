defmodule Jumpa.Repo do
  use Ecto.Repo,
    otp_app: :jumpa,
    adapter: Ecto.Adapters.Postgres
end
