defmodule GenGameWeb.Router do
  use GenGameWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  get "/", GenGameWeb.Controllers.IndexController, :index

  scope "/api", GenGameWeb.Controllers do
    pipe_through :api
  end
end
