defmodule JumpaApp.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :code, :string
      add :region, :string

      timestamps()
    end
  end
end
