defmodule GenGameWeb.Api.HomeView do
  use GenGameWeb, :view

  def render("index.json", _data) do
    %{status: "ok", service: "gen_game_api"}
  end
end
