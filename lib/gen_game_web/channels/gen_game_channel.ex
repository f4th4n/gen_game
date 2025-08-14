defmodule GenGameWeb.Channels.GenGameChannel do
  @moduledoc """
  This channel is used for create a game.
  """

  use GenGameWeb, :channel

  require Logger

  alias GenGameWeb.RequestHandlers.AccountHandler
  alias GenGameWeb.RequestHandlers.GameHandler
  alias GenGameWeb.RequestHandlers.OauthLinkHandler

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

  def handle_in("get_last_match_id", params, socket),
    do: GameHandler.get_last_match_id(params, socket)

  def handle_in("rpc", params, socket),
    do: GameHandler.rpc(params, socket)

  # OAuth link management
  def handle_in("list_oauth_links", params, socket),
    do: OauthLinkHandler.list_oauth_links(params, socket)

  def handle_in("unlink_oauth_provider", params, socket),
    do: OauthLinkHandler.unlink_oauth_provider(params, socket)
end
