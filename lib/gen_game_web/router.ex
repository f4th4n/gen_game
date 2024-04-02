defmodule GenGameWeb.Router do
  use GenGameWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GenGameWeb.Controllers do
    pipe_through :api
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:gen_game, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: GenGameWeb.Telemetry
    end
  end
end
