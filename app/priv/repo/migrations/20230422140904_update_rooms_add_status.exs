defmodule GenGameApp.Repo.Migrations.UpdateRoomsAddStatus do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :status, :string, default: "open"
    end
  end
end
