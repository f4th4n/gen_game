defmodule GenGameWeb.Channels.GenGameChannel do
  @moduledoc """
  This channel is used for authentication, wallet, user management.
  """

  use GenGameWeb, :channel

  alias GenGameWeb.Channels.SessionHandler
  alias GenGameWeb.Channels.AccountHandler

  @impl true
  def join("gg", _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("create_session", params, socket),
    do: SessionHandler.create_session(params, socket)

  def handle_in("create_account", params, socket),
    do: AccountHandler.create_account(params, socket)
end
