defmodule GenGameWeb.RequestHandlers.OauthLinkHandler do
  require Logger

  alias GenGame.Account.Accounts

  @doc """
  Unlink OAuth provider from account
  """
  def unlink_oauth_provider(%{"provider" => provider}, socket) do
    token = socket.assigns.token
    with {:ok, username} <- GenGame.PlayerSession.verify(token),
         account when not is_nil(account) <- Accounts.get_by_username(username),
         :ok <- Accounts.unlink_oauth_provider(account, provider) do
      Logger.info("[OauthLinkHandler] Unlinked #{provider} from account #{username}")
      {:reply, {:ok, %{message: "Provider unlinked successfully"}}, socket}
    else
      nil ->
        {:reply, {:error, %{msg: "Account not found"}}, socket}
      {:error, :provider_not_linked} ->
        {:reply, {:error, %{msg: "Provider not linked to this account"}}, socket}
      err ->
        Logger.error("[OauthLinkHandler] Failed to unlink provider: #{inspect(err)}")
        {:reply, {:error, %{msg: "Invalid request"}}, socket}
    end
  end

  @doc """
  List OAuth providers linked to account
  """
  def list_oauth_links(_params, socket) do
    token = socket.assigns.token

    with {:ok, username} <- GenGame.PlayerSession.verify(token),
         account when not is_nil(account) <- Accounts.get_by_username(username) do
      providers = Accounts.list_linked_providers(account)

      {:reply,
       {:ok,
        %{
          linked_providers: providers
        }}, socket}
    else
      nil ->
        {:reply, {:error, %{msg: "Account not found"}}, socket}
      err ->
        Logger.warning("[OauthLinkHandler] Failed to list OAuth links: #{inspect(err)}")
        {:reply, {:error, %{msg: "Failed to list OAuth links"}}, socket}
    end
  end
end
