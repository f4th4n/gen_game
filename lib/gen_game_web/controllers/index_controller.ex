defmodule GenGameWeb.Controllers.IndexController do
  use GenGameWeb, :controller

  def index(conn, _) do
    json(conn, %{app: "gen_game", status: "ok"})
  end
end
