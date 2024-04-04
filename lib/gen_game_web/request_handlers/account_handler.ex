defmodule GenGameWeb.RequestHandlers.AccountHandler do
  alias GenGame.Account.Account
  alias GenGame.Account.Accounts
  alias GenGame.ChangesetHelper

  def create_account(payload, socket) do
    case Accounts.create_account(payload) do
      {:ok, %Account{} = account} ->
        {:reply, {:ok, account}, socket}

      {:error, cs} ->
        msg = %{msg: ChangesetHelper.traverse_errors(cs)}
        {:reply, {:error, msg}, socket}
    end
  end
end
