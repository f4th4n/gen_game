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

    # Subscribe to OAuth result events for this token
    topic = "oauth_result:#{token}"
    Phoenix.PubSub.subscribe(GenGame.PubSub, topic)
    Logger.debug("[GenGameChannel] Subscribed to OAuth result topic: #{topic}")

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

  # Handle OAuth result broadcasts from PubSub
  @impl true
  def handle_info({:oauth_result, result}, socket) do
    Logger.debug("[GenGameChannel] Received OAuth result via PubSub, pushing to client")
    Logger.debug("[GenGameChannel] OAuth result data: #{inspect(result)}")
    push(socket, "oauth_result", result)
    {:noreply, socket}
  end

  # Catch-all for other messages to debug what's being received
  @impl true
  def handle_info(message, socket) do
    Logger.warning("[GenGameChannel] Received unhandled message: #{inspect(message)}")
    {:noreply, socket}
  end
end
