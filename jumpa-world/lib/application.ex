defmodule JumpaWorld.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.inspect({"Application...."})
    children = [
      Jumpa.GameSpv
    ]

    opts = [strategy: :one_for_one, name: Jumpa.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
