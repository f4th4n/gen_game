defmodule GenGame.Account.OauthLink do
  use Ecto.Schema
  import Ecto.Changeset

  alias GenGame.Account.Account

  @required_fields [:account_id, :provider, :provider_uid]
  @optional_fields []
  @all_fields @required_fields ++ @optional_fields

  @json_fields [:id, :provider, :provider_uid, :account_id]

  @derive {Jason.Encoder, only: @json_fields}
  schema "oauth_links" do
    field :provider, :string
    field :provider_uid, :string

    belongs_to :account, Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(oauth_link, attrs) do
    oauth_link
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:provider, ~w(google github facebook twitter discord apple steam))
    |> unique_constraint([:provider, :provider_uid], name: :oauth_links_provider_uid_index)
    |> unique_constraint([:account_id, :provider], name: :oauth_links_account_provider_index)
    |> foreign_key_constraint(:account_id)
  end

  @doc """
  Build changeset from OAuth auth data
  """
  def from_oauth_changeset(oauth_link, account_id, auth) do
    attrs = %{
      account_id: account_id,
      provider: to_string(auth.provider),
      provider_uid: auth.uid
    }

    changeset(oauth_link, attrs)
  end
end
