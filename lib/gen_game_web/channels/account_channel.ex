defmodule GenGameWeb.AccountChannel do
  use GenGameWeb, :channel

  require Logger

  alias GenGame.Account.Accounts
  alias GenGame.Account.Account
  alias GenGame.ChangesetHelper

  # events_in = [
  #   "create_account",
  #   "get"
  # ]

  @impl true
  def join("account", %{"device_id" => device_id}, socket) do
    {:ok, assign(socket, :device_id, device_id)}
  end

  @impl true
  def handle_in("create_account", payload, socket) do
    case Accounts.create_account(payload) do
      {:ok, %Account{} = account} ->
        {:reply, {:ok, account}, socket}

      {:error, cs} ->
        msg = %{msg: ChangesetHelper.traverse_errors(cs)}
        {:reply, {:error, msg}, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
