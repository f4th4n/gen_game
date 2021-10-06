defmodule JumpaWeb.Api.HomeController do
  use JumpaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json")
  end
end
