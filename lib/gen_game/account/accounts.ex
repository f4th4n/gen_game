defmodule GenGame.Account.Accounts do
  import Ecto.Query, warn: false

  alias GenGame.Repo
  alias GenGame.Account.Account

  def get_account(id) do
    Repo.get(Account, id)
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
end
