defmodule JumpaWeb.Api.HomeView do
  use JumpaWeb, :view

  def render("index.json", _data) do
    %{status: "ok"}
  end
end
