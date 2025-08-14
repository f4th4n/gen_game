defmodule GenGameWeb.Router do
  use GenGameWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  get "/", GenGameWeb.Controllers.IndexController, :index

  # OAuth routes for social login and account linking
  scope "/auth", GenGameWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/api", GenGameWeb.Controllers do
    pipe_through :api
  end
end
