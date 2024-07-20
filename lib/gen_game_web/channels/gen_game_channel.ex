defmodule GenGameWeb.Channels.GenGameChannel do
  @moduledoc """
  This channel is used for create a game.
  """

  use GenGameWeb, :channel

  alias GenGameWeb.RequestHandlers.AccountHandler
  alias GenGameWeb.RequestHandlers.GameHandler

  @impl true
  def join("gen_game", %{"token" => token}, socket) do
    {:ok, assign(socket, token: token)}
  end

  @impl true

  def handle_in("create_account", params, socket),
    do: AccountHandler.create_account(params, socket)

  def handle_in("create_match", params, socket),
    do: GameHandler.create_match(params, socket)

  def handle_in("rpc", params, socket),
    do: GameHandler.rpc(params, socket)
end
