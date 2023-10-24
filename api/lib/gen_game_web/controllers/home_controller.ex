defmodule GenGameWeb.Api.HomeController do
  use GenGameWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json")
  end
end
