defmodule GenGame.Account.Accounts do
  import Ecto.Query, warn: false

  alias GenGame.Repo
  alias GenGame.Account.Account
  alias GenGame.Account.OauthLink

  def get_account(id) do
    Repo.get(Account, id)
  end

  @doc """
  Get account by username
  """
  @spec get_by_username(username :: String.t()) :: Ecto.Schema.t() | nil
  def get_by_username(username) when is_binary(username) do
    Repo.get_by(Account, username: username)
  end

  @doc """
  Get account by OAuth provider UID
  """
  def get_by_oauth_provider(provider, uid) when is_binary(provider) and is_binary(uid) do
    query = from a in Account,
          join: ol in OauthLink, on: ol.account_id == a.id,
          where: ol.provider == ^provider and ol.provider_uid == ^uid,
          select: a,
          preload: [:oauth_links]

    Repo.one(query)
  end

  @doc """
  Get all OAuth links for an account
  """
  def get_oauth_links(%Account{id: account_id}) do
    Repo.all(from ol in OauthLink, where: ol.account_id == ^account_id)
  end

  @doc """
  Check if account has specific OAuth provider linked
  """
  def has_oauth_provider?(%Account{id: account_id}, provider) do
    query = from ol in OauthLink,
            where: ol.account_id == ^account_id and ol.provider == ^provider

    Repo.exists?(query)
  end

  @spec create_account(map()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_account(map(), map()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Link OAuth provider to existing account
  """
  def link_oauth_provider(%Account{id: account_id} = account, auth_data) do
    # Check if already linked to this provider
    if has_oauth_provider?(account, to_string(auth_data.provider)) do
      {:error, :provider_already_linked}
    else
      %OauthLink{}
      |> OauthLink.from_oauth_changeset(account_id, auth_data)
      |> Repo.insert()
      |> case do
        {:ok, _oauth_link} ->
          # Return updated account with OAuth links preloaded
          {:ok, Repo.preload(account, :oauth_links, force: true)}
        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  @doc """
  Unlink OAuth provider from account
  """
  def unlink_oauth_provider(%Account{id: account_id}, provider) do
    query = from ol in OauthLink,
            where: ol.account_id == ^account_id and ol.provider == ^provider

    case Repo.delete_all(query) do
      {1, _} -> :ok
      {0, _} -> {:error, :provider_not_linked}
    end
  end

  @doc """
  Check if account can use social login (has real username)
  """
  def can_use_social_login?(%Account{username: username}) when is_binary(username) do
    # For now, any account with username can use social login
    # Later we can add logic to check if it's not a temporary account
    true
  end
  def can_use_social_login?(_), do: false

  @doc """
  List all providers linked to an account
  """
  def list_linked_providers(%Account{id: account_id}) do
    query = from ol in OauthLink,
            where: ol.account_id == ^account_id,
            select: ol.provider

    Repo.all(query)
  end
end
