defmodule GenGameWeb.Channels.GenGameChannel do
  @moduledoc """
  This channel is used for create a game.
  """

  use GenGameWeb, :channel

  require Logger

  alias GenGameWeb.RequestHandlers.AccountHandler
  alias GenGameWeb.RequestHandlers.GameHandler

  @impl true
  def join("gen_game", %{"token" => token}, socket) do
    Logger.info("[GenGameChannel] join channel GenGame, token=#{inspect(token)}")

    {:ok, assign(socket, token: token)}
  end

  @impl true

  def handle_in("create_account", params, socket),
    do: AccountHandler.create_account(params, socket)

  def handle_in("create_match", params, socket),
    do: GameHandler.create_match(params, socket)

  def handle_in("request_match", params, socket),
    do: GameHandler.request_match(params, socket)

  # TODO: add other CRUD for request match (- update),

  def handle_in("get_last_match_id", params, socket),
    do: GameHandler.get_last_match_id(params, socket)

  def handle_in("rpc", params, socket),
    do: GameHandler.rpc(params, socket)
end
