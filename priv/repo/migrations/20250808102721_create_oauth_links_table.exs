defmodule GenGame.Repo.Migrations.CreateOauthLinksTable do
  use Ecto.Migration

  def change do
    create table(:oauth_links) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :provider, :string, null: false
      add :provider_uid, :string, null: false

      timestamps(type: :utc_datetime)
    end

    # Ensure one account can't have duplicate providers with same UID
    create unique_index(:oauth_links, [:provider, :provider_uid],
             name: :oauth_links_provider_uid_index
           )

    # Ensure one account can't link same provider multiple times
    create unique_index(:oauth_links, [:account_id, :provider],
             name: :oauth_links_account_provider_index
           )

    # Index for fast lookups
    create index(:oauth_links, [:account_id])
    create index(:oauth_links, [:provider])
  end
end
