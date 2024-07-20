defmodule GenGameWeb.RequestHandlers.AccountHandler do
  import GenGame.ServerAuthoritative

  alias GenGame.Account.Account
  alias GenGame.Account.Accounts
  alias GenGame.ChangesetHelper

  def create_account(payload, socket) do
    dispatch_event(:before_create_account, %{payload: payload, socket: socket})

    case Accounts.create_account(payload) do
      {:ok, %Account{} = account} ->
        dispatch_event(:after_create_account, %{account: account, socket: socket})

        {:reply, {:ok, account}, socket}

      {:error, cs} ->
        msg = %{msg: ChangesetHelper.traverse_errors(cs)}
        {:reply, {:error, msg}, socket}
    end
  end
end
