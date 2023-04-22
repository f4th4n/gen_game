defmodule Jumpa.Repo do
  use Ecto.Repo,
    otp_app: :jumpa_api,
    adapter: Ecto.Adapters.Postgres
end
