defmodule Jumpa.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :nick, :string
      add :room_id, :string

      timestamps()
    end
  end
end
