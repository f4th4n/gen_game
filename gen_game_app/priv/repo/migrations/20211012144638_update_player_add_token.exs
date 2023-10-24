defmodule GenGameApp.Repo.Migrations.UpdatePlayerAddToken do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :token, :string, default: ""
    end
  end
end
