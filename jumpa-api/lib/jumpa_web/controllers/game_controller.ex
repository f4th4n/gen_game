defmodule JumpaWeb.GameController do
  use JumpaWeb, :controller

  alias JumpaApi.Game

  action_fallback JumpaWeb.FallbackController

  def new(conn, params) do
    #render(conn, "show.json", player: params)

    :something
  end
end
