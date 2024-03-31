defmodule GenGame.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :username, :string
      add :display_name, :string
      add :avatar_url, :string
      add :lang, :string, default: "en"
      add :timezone, :string
      add :metadata, :string

      add :steam_id, :string
      add :facebook_id, :string
      add :google_id, :string
      add :gamecenter_id, :string
      add :online, :boolean

      timestamps()
    end

    create index(:accounts, [:username], unique: true)
  end
end
